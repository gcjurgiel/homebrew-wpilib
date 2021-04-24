cask 'wpilib' do
  version '2021.2.2'
  sha256 '11f70c4ddf0ae55701dfddbc19412746d8b538b0397756363ae6b19cdd897c3b'

  # github.com/wpilibsuite/allwpilib was verified as official when first introduced to the cask
  url "https://github.com/wpilibsuite/allwpilib/releases/download/v#{version}/WPILib_macOS-#{version}.dmg"
  appcast 'https://github.com/wpilibsuite/allwpilib/releases.atom'
  name 'WPILib Suite'
  homepage 'https://wpilib.org/'

  depends_on cask: 'visual-studio-code'

  year = "#{version.split('.', -1)[0]}"
  install_dir = "#{ENV['HOME']}/wpilib/#{year}"

  artifact 'artifacts', target: install_dir

  preflight do
    system_command 'mkdir', args: ['-p', "#{staged_path}/artifacts"]
    system_command 'xattr', args: ['-d', 'com.apple.quarantine', "#{staged_path}/WPILib_Mac-#{version}-artifacts.tar.gz"]
    system_command 'tar', args: ['-zxf', "#{staged_path}/WPILib_Mac-#{version}-artifacts.tar.gz", '-C', "#{staged_path}/artifacts"]

    system_command '/usr/bin/python', args: ["#{staged_path}/artifacts/tools/ToolsUpdater.py"]

    Dir.glob("#{staged_path}/artifacts/vsCodeExtensions/*.vsix") do |vsix_file|
      system_command "#{ENV['HOMEBREW_PREFIX']}/bin/code", args: ['--install-extension', vsix_file]
    end

    system_command 'rm', args: ["#{staged_path}/WPILib_Mac-#{version}-artifacts.tar.gz"]
    system_command 'rm', args: ['-rf', "#{staged_path}/WPILibInstaller.app"]
  end

  uninstall_preflight do
    system_command "#{ENV['HOMEBREW_PREFIX']}/bin/code", args: ['--uninstall-extension', 'wpilibsuite.vscode-wpilib']
  end
end
