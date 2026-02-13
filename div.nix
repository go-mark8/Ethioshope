{ pkgs, ... }: {
  # Use a stable channel for reliable package versions
  channel = "stable-23.11"; 

  # 1. System Packages
  packages = [
    pkgs.jdk17        # Required for Android Gradle builds
    pkgs.unzip        # Utility often needed by Gradle
    pkgs.clang        # Build tools for compiling C++ dependencies
    pkgs.cmake
    pkgs.ninja
    pkgs.pkg-config
  ];

  # 2. Environment Variables
  env = {};

  idx = {
    # 3. Essential Extensions
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
      "GoogleCloudTools.cloudcode" # Great for viewing Firebase/GCP resources inside IDX
    ];

    # 4. Previews (Android Emulator & Web)
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT"];
          manager = "flutter";
        };
        android = {
          command = ["flutter" "run" "--machine" "-d" "android" "-d" "localhost:5555"];
          manager = "flutter";
        };
      };
    };

    # 5. Lifecycle Hooks
    workspace = {
      # Runs only when the workspace is first created
      onCreate = {
        build-flutter = ''
          flutter pub get
          # Automatically run build_runner since it is in your dev_dependencies
          dart run build_runner build --delete-conflicting-outputs
        '';
      };
      
      # Runs every time you open the workspace
      onStart = {
        # Ensure dependencies are always up to date
        get-dependencies = "flutter pub get";
      };
    };
  };
}
