using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Windows.Forms;

internal static class StartLauncher
{
    [STAThread]
    private static int Main(string[] args)
    {
        string appRoot = AppDomain.CurrentDomain.BaseDirectory.TrimEnd(
            Path.DirectorySeparatorChar,
            Path.AltDirectorySeparatorChar);
        string appScript = Path.Combine(appRoot, "App.ps1");
        string iconPath = Path.Combine(appRoot, "Assets", "MaxMovLauncher.ico");
        string powershell = ResolvePowerShell(appRoot);

        if (args.Length == 1 && string.Equals(args[0], "--self-test", StringComparison.OrdinalIgnoreCase))
        {
            return File.Exists(appScript) && File.Exists(iconPath) && !string.IsNullOrWhiteSpace(powershell) ? 0 : 2;
        }

        if (!File.Exists(appScript))
        {
            ShowError("Файл App.ps1 не найден рядом с Start.exe.");
            return 2;
        }
        if (string.IsNullOrWhiteSpace(powershell))
        {
            ShowError("PowerShell не найден. Windows PowerShell 5.1 входит в состав поддерживаемых версий Windows.");
            return 2;
        }

        List<string> powershellArguments = new List<string>
        {
            "-STA",
            "-NoLogo",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-WindowStyle",
            "Hidden",
            "-File",
            appScript
        };

        try
        {
            ProcessStartInfo startInfo = new ProcessStartInfo
            {
                FileName = powershell,
                Arguments = JoinArguments(powershellArguments),
                WorkingDirectory = appRoot,
                WindowStyle = ProcessWindowStyle.Hidden,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using (Process process = Process.Start(startInfo))
            {
            }
            return 0;
        }
        catch (Exception exception)
        {
            ShowError("Не удалось запустить Audion Windows Tools by Max.mov.\r\n\r\n" + exception.Message);
            return 1;
        }
    }

    private static string ResolvePowerShell(string appRoot)
    {
        string portable = Path.Combine(appRoot, "Engine", "PowerShell", "pwsh.exe");
        if (File.Exists(portable))
        {
            return portable;
        }

        string systemPwsh = FindOnPath("pwsh.exe");
        if (!string.IsNullOrWhiteSpace(systemPwsh))
        {
            return systemPwsh;
        }

        string windowsRoot = Environment.GetEnvironmentVariable("WINDIR") ?? string.Empty;
        if (!string.IsNullOrWhiteSpace(windowsRoot))
        {
            string windowsPowerShell = Path.Combine(
                windowsRoot,
                "System32",
                "WindowsPowerShell",
                "v1.0",
                "powershell.exe");
            if (File.Exists(windowsPowerShell))
            {
                return windowsPowerShell;
            }
        }

        return FindOnPath("powershell.exe");
    }

    private static string FindOnPath(string executableName)
    {
        string path = Environment.GetEnvironmentVariable("PATH") ?? string.Empty;
        foreach (string folder in path.Split(Path.PathSeparator))
        {
            if (string.IsNullOrWhiteSpace(folder))
            {
                continue;
            }
            try
            {
                string candidate = Path.Combine(folder.Trim(), executableName);
                if (File.Exists(candidate))
                {
                    return candidate;
                }
            }
            catch
            {
            }
        }
        return string.Empty;
    }

    private static string JoinArguments(IEnumerable<string> arguments)
    {
        StringBuilder commandLine = new StringBuilder();
        foreach (string argument in arguments)
        {
            if (commandLine.Length > 0)
            {
                commandLine.Append(' ');
            }
            commandLine.Append(QuoteArgument(argument));
        }
        return commandLine.ToString();
    }

    private static string QuoteArgument(string value)
    {
        if (value == null)
        {
            value = string.Empty;
        }
        if (value.Length > 0 && value.IndexOfAny(new[] { ' ', '\t', '\n', '\v', '"' }) < 0)
        {
            return value;
        }

        StringBuilder quoted = new StringBuilder("\"");
        int backslashes = 0;
        foreach (char character in value)
        {
            if (character == '\\')
            {
                backslashes++;
                continue;
            }
            if (character == '"')
            {
                quoted.Append('\\', (backslashes * 2) + 1);
                quoted.Append('"');
                backslashes = 0;
                continue;
            }
            quoted.Append('\\', backslashes);
            backslashes = 0;
            quoted.Append(character);
        }
        quoted.Append('\\', backslashes * 2);
        quoted.Append('"');
        return quoted.ToString();
    }

    private static void ShowError(string message)
    {
        MessageBox.Show(
            message,
            "Audion Windows Tools by Max.mov",
            MessageBoxButtons.OK,
            MessageBoxIcon.Error);
    }
}
