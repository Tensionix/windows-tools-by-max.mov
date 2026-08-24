# UTF-8 without BOM
Set-StrictMode -Version Latest

function Set-AwtWindowIdentity {
    param(
        [Parameter(Mandatory)][System.Windows.Window]$Window,
        [Parameter(Mandatory)][string]$AppRoot
    )

    try {
        if (-not ('Audion.WindowsTools.NativeTaskbar' -as [type])) {
            Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;

namespace Audion.WindowsTools
{
    [StructLayout(LayoutKind.Sequential, Pack = 4)]
    public struct PropertyKey
    {
        public System.Guid FormatId;
        public uint PropertyId;

        public PropertyKey(System.Guid formatId, uint propertyId)
        {
            FormatId = formatId;
            PropertyId = propertyId;
        }
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct PropVariant
    {
        [FieldOffset(0)] public ushort VariantType;
        [FieldOffset(8)] public System.IntPtr PointerValue;
    }

    [ComImport]
    [Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IPropertyStore
    {
        [PreserveSig] int GetCount(out uint propertyCount);
        [PreserveSig] int GetAt(uint propertyIndex, out PropertyKey key);
        [PreserveSig] int GetValue(ref PropertyKey key, out PropVariant value);
        [PreserveSig] int SetValue(ref PropertyKey key, ref PropVariant value);
        [PreserveSig] int Commit();
    }

    public static class NativeTaskbar
    {
        private static readonly System.Guid AppUserModelFormatId = new System.Guid("9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3");
        private static readonly System.Guid PropertyStoreInterfaceId = new System.Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99");
        private const uint RelaunchCommandPropertyId = 2;
        private const uint RelaunchIconResourcePropertyId = 3;
        private const uint RelaunchDisplayNameResourcePropertyId = 4;
        private const uint AppUserModelIdPropertyId = 5;
        private const uint WindowSetIconMessage = 0x0080;
        private const uint ImageIcon = 1;
        private const uint LoadFromFile = 0x0010;

        [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
        public static extern int SetCurrentProcessExplicitAppUserModelID(string appId);

        [DllImport("shell32.dll")]
        private static extern int SHGetPropertyStoreForWindow(
            System.IntPtr windowHandle,
            ref System.Guid interfaceId,
            [Out, MarshalAs(UnmanagedType.Interface)] out IPropertyStore propertyStore);

        [DllImport("ole32.dll", PreserveSig = true)]
        private static extern int PropVariantClear(ref PropVariant propVariant);

        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern System.IntPtr LoadImage(
            System.IntPtr instance,
            string imagePath,
            uint imageType,
            int width,
            int height,
            uint loadFlags);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern System.IntPtr SendMessage(
            System.IntPtr windowHandle,
            uint message,
            System.IntPtr wordParameter,
            System.IntPtr longParameter);

        private static bool SetString(IPropertyStore store, uint propertyId, string value)
        {
            PropertyKey key = new PropertyKey(AppUserModelFormatId, propertyId);
            PropVariant variant = new PropVariant();
            variant.VariantType = 31; // VT_LPWSTR
            variant.PointerValue = Marshal.StringToCoTaskMemUni(value);
            try
            {
                return store.SetValue(ref key, ref variant) >= 0;
            }
            finally
            {
                PropVariantClear(ref variant);
            }
        }

        public static bool SetWindowIcons(System.IntPtr windowHandle, string iconPath)
        {
            System.IntPtr smallIcon = LoadImage(System.IntPtr.Zero, iconPath, ImageIcon, 16, 16, LoadFromFile);
            System.IntPtr largeIcon = LoadImage(System.IntPtr.Zero, iconPath, ImageIcon, 32, 32, LoadFromFile);
            if (smallIcon != System.IntPtr.Zero)
            {
                SendMessage(windowHandle, WindowSetIconMessage, System.IntPtr.Zero, smallIcon);
                SendMessage(windowHandle, WindowSetIconMessage, new System.IntPtr(2), smallIcon);
            }
            if (largeIcon != System.IntPtr.Zero)
            {
                SendMessage(windowHandle, WindowSetIconMessage, new System.IntPtr(1), largeIcon);
            }
            // Handles intentionally live until this short-lived GUI process exits.
            return smallIcon != System.IntPtr.Zero && largeIcon != System.IntPtr.Zero;
        }

        public static bool SetWindowIdentity(
            System.IntPtr windowHandle,
            string appId,
            string relaunchCommand,
            string displayName,
            string iconResource)
        {
            IPropertyStore store = null;
            System.Guid interfaceId = PropertyStoreInterfaceId;
            if (SHGetPropertyStoreForWindow(windowHandle, ref interfaceId, out store) < 0 || store == null) return false;
            try
            {
                // Relaunch properties must be present before the explicit window AppUserModelID.
                bool commandSet = SetString(store, RelaunchCommandPropertyId, relaunchCommand);
                bool iconSet = SetString(store, RelaunchIconResourcePropertyId, iconResource);
                bool nameSet = SetString(store, RelaunchDisplayNameResourcePropertyId, displayName);
                bool idSet = SetString(store, AppUserModelIdPropertyId, appId);
                bool committed = store.Commit() >= 0;
                return commandSet && iconSet && nameSet && idSet && committed;
            }
            finally
            {
                Marshal.ReleaseComObject(store);
            }
        }
    }
}
'@
        }
        [void][Audion.WindowsTools.NativeTaskbar]::SetCurrentProcessExplicitAppUserModelID('Audion.WindowsTools.MaxMov')
    } catch {}

    $iconPath = Join-Path $AppRoot 'Assets\MaxMovLauncher.ico'
    $startPath = Join-Path $AppRoot 'Start.exe'
    if (Test-Path -LiteralPath $startPath -PathType Leaf) {
        $appId = 'Audion.WindowsTools.MaxMov'
        $relaunchCommand = '"' + $startPath + '"'
        $displayName = 'Audion Windows Tools by Max.mov'
        $iconResource = $startPath + ',-32512'
        $helper = [System.Windows.Interop.WindowInteropHelper]::new($Window)
        $windowHandle = $helper.EnsureHandle()
        $iconsApplied = [Audion.WindowsTools.NativeTaskbar]::SetWindowIcons($windowHandle, $iconPath)
        $identityApplied = [Audion.WindowsTools.NativeTaskbar]::SetWindowIdentity(
            $windowHandle,
            $appId,
            $relaunchCommand,
            $displayName,
            $iconResource
        )
        if (-not $iconsApplied -or -not $identityApplied) {
            throw 'Could not assign the Audion Windows Tools taskbar icon and application identity.'
        }
        $applyNativeIdentity = {
            param($sender, $eventArgs)
            try {
                $helper = [System.Windows.Interop.WindowInteropHelper]::new([System.Windows.Window]$sender)
                [void][Audion.WindowsTools.NativeTaskbar]::SetWindowIcons($helper.Handle, $iconPath)
                [void][Audion.WindowsTools.NativeTaskbar]::SetWindowIdentity(
                    $helper.Handle,
                    $appId,
                    $relaunchCommand,
                    $displayName,
                    $iconResource
                )
            } catch {}
        }.GetNewClosure()
        $Window.Add_ContentRendered($applyNativeIdentity)
    }

    if (-not (Test-Path -LiteralPath $iconPath -PathType Leaf)) { return }

    $stream = $null
    try {
        $stream = [System.IO.File]::OpenRead($iconPath)
        $decoder = [System.Windows.Media.Imaging.IconBitmapDecoder]::new(
            $stream,
            [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,
            [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        )
        $frame = $decoder.Frames | Sort-Object PixelWidth -Descending | Select-Object -First 1
        if ($frame) {
            if ($frame.CanFreeze -and -not $frame.IsFrozen) { $frame.Freeze() }
            $Window.Icon = $frame
        }
    } catch {
    } finally {
        if ($stream) { $stream.Dispose() }
    }
}

Export-ModuleMember -Function Set-AwtWindowIdentity
