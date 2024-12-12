#!/usr/bin/env bash
#SUPREME TEAM 

rp_module_id="rpcs3"
rp_module_desc="RPCS3 - PS3 Emulator (AppImage)"
rp_module_licence="RPCS3 https://rpcs3.net/terms"
rp_module_section="exp"  # "emulators" section
rp_module_flags="!x86"  # Excludes x86 (only for ARM systems)

RPCS3_VERSION="v0.0.34-17173-68b7e597"
RPCS3_APPIMAGE_URL="https://github.com/RPCS3/rpcs3-binaries-linux-arm64/releases/download/build-68b7e5971d8e279d7d385b96b5aa2feebd220506/rpcs3-${RPCS3_VERSION}_linux_aarch64.AppImage"
RPCS3_APPIMAGE_NAME="rpcs3-${RPCS3_VERSION}_linux_aarch64.AppImage"
PS3_ROMS_DIR="/home/pi/RetroPie/roms/ps3"
PS3_SCRIPTMODULES_EMU_DIR="/home/pi/RetroPie-Setup/scriptmodules/emulators/"
RPCS3_PATH="/opt/retropie/emulators/rpcs3/"
RPCS3_BOXART_ICON_PATH="$PS3_ROMS_DIR/boxart/PS3.png"
RPCS3_MARQUEE_PATH="$PS3_ROMS_DIR/marquee/PS3.png"
RPCS3_SNAP_PATH="$PS3_ROMS_DIR/snap/PS3.mp4"
PS3_FIRMWARE_URL="http://dus01.ps3.update.playstation.net/update/ps3/image/us/2024_0227_3694eb3fb8d9915c112e6ab41a60c69f/PS3UPDAT.PUP"
PS3_FIRMWARE_PATH="/home/pi/RetroPie/BIOS/ps3/PS3UPDAT.PUP"

# Function to handle dependencies
function depends_rpcs3() {
    getDepends libfuse2 libsdl2-dev libvulkan1 dialog
}

# Function to handle the download of RPCS3 AppImage
function sources_rpcs3() {
    download "$RPCS3_APPIMAGE_URL" "$md_build"
}

# Function to download the PS3 firmware
function download_ps3_firmware() {
    # Create the directory for PS3 firmware if it does not exist
    mkdir -p "/home/pi/RetroPie/BIOS/ps3"

    # Check if the firmware is already downloaded
    if [[ ! -f "$PS3_FIRMWARE_PATH" ]]; then
        echo "Downloading PS3 firmware..."
        wget -O "$PS3_FIRMWARE_PATH" "$PS3_FIRMWARE_URL" || { echo "Failed to download PS3 firmware"; exit 1; }
        echo "PS3 firmware downloaded to $PS3_FIRMWARE_PATH"
    else
        echo "PS3 firmware already downloaded at $PS3_FIRMWARE_PATH"
    fi
}

# Function to install RPCS3
function install_rpcs3() {
    # Ensure the correct path for the PS3 ROMs directory
    echo "Using PS3_ROMS_DIR: $PS3_ROMS_DIR"

    # Use RetroPie's mkRomDir to create the PS3 ROMs directory
    mkRomDir "ps3"

    # Create necessary directories inside the PS3 ROMs folder
    mkdir -p "$PS3_ROMS_DIR/boxart"
    mkdir -p "$PS3_ROMS_DIR/marquee"
    mkdir -p "$PS3_ROMS_DIR/snap"

    # Make the AppImage executable and move it to the proper location
    chmod +x "$md_build/$RPCS3_APPIMAGE_NAME"
    mv "$md_build/$RPCS3_APPIMAGE_NAME" "$md_inst/rpcs3.AppImage"

    # Download the PS3 firmware
    download_ps3_firmware

    # Create +Start RPCS3 script
    echo "Creating the +Start RPCS3 script..."
    cat > "$PS3_ROMS_DIR/RPCS3.sh" <<EOF
#!/bin/bash
"/opt/retropie/supplementary/runcommand/runcommand.sh" 0 _SYS_ "ps3" ""
EOF

    # Make sure the start script is executable
    chmod +x "$PS3_ROMS_DIR/RPCS3.sh"

    # Ensure the file was created
    if [[ ! -f "$PS3_ROMS_DIR/RPCS3.sh" ]]; then
        echo "Error: Failed to create +Start RPCS3.sh script in $PS3_ROMS_DIR"
        exit 1
    fi

    # Copy the icons and snaps from the RetroPie-Setup scriptmodules RPCS3 directory
    echo "Copying RPCS3 icon to RPCS3 directory..."
    if [[ ! -f "$RPCS3_ICON_PATH" ]]; then
        cp "$PS3_SCRIPTMODULES_EMU_DIR/rpcs3/boxart/PS3.png" "$RPCS3_PATH/rpcs3.png"
        echo "RPCS3 icon copied to $RPCS3_ICON_PATH"
    fi

    # Copy the icon to the boxart directory
    echo "Copying RPCS3 icon to boxart directory..."
    if [[ ! -f "$RPCS3_BOXART_ICON_PATH" ]]; then
        cp "$PS3_SCRIPTMODULES_EMU_DIR/rpcs3/boxart/PS3.png" "$RPCS3_BOXART_ICON_PATH"
        echo "RPCS3 icon copied to boxart as $RPCS3_BOXART_ICON_PATH"
    fi

    # Copy the marquee image and save it in the marquee directory
    echo "Copying RPCS3 marquee image..."
    if [[ ! -f "$RPCS3_MARQUEE_PATH" ]]; then
        cp "$PS3_SCRIPTMODULES_EMU_DIR/rpcs3/marquee/PS3.png" "$RPCS3_MARQUEE_PATH"
        echo "RPCS3 marquee image copied to $RPCS3_MARQUEE_PATH"
    fi
    
    # Copy the snap and save it in the snap directory
    echo "Copying RPCS3 snap..."
    if [[ ! -f "$RPCS3_SNAP_PATH" ]]; then
        cp "$PS3_SCRIPTMODULES_EMU_DIR/rpcs3/snap/PS3.mp4" "$RPCS3_SNAP_PATH"
        echo "RPCS3 snap copied to $RPCS3_SNAP_PATH"
    fi

    # Create the gamelist.xml manually
    echo "Creating gamelist.xml..."
    if [[ ! -f "$PS3_ROMS_DIR/gamelist.xml" ]]; then
        cat > "$PS3_ROMS_DIR/gamelist.xml" <<EOF
<?xml version="1.0"?>
<gameList>
    <provider>
        <System>ps3</System>
        <software>RPCS3</software>
    </provider>
    <game>
        <path>./RPCS3.sh</path>
        <name>+Start RPCS3</name>
        <desc>RPCS3 is a PS3 emulator for Linux. Use it to play PS3 games on your system.</desc>
        <image>./boxart/PS3.png</image>
        <marquee>./marquee/PS3.png</marquee>
        <video>./snap/PS3.mp4</video>
        <rating>0.95</rating>
        <releasedate>20231210T000000</releasedate>
        <developer>RPCS3 Team</developer>
        <publisher>RPCS3</publisher>
        <genre>Emulator</genre>
    </game>
</gameList>
EOF
        echo "gamelist.xml created at $PS3_ROMS_DIR"
    fi

    # Ensure all files in PS3_ROMS_DIR are owned by the pi user
    echo "Ensuring ownership of PS3_ROMS_DIR by pi user..."
    chown -R pi:pi "$PS3_ROMS_DIR"

    # Add emulator entry to es_systems.cfg if not already present
    echo "Adding emulator entry to es_systems.cfg..."
    ES_SYSTEMS_CFG1="/opt/retropie/configs/all/emulationstation/es_systems.cfg"
    ES_SYSTEMS_CFG2="/etc/emulationstation/es_systems.cfg"

    for ES_SYSTEMS_CFG in "$ES_SYSTEMS_CFG1" "$ES_SYSTEMS_CFG2"; do
        if [[ -f "$ES_SYSTEMS_CFG" ]]; then
            # Check if PS3 entry exists and add it if necessary
            if ! grep -q '<name>ps3</name>' "$ES_SYSTEMS_CFG"; then
                # Add the new PS3 entry
                sed -i '/<\/systemList>/i \
  <system> \
    <name>ps3</name> \
    <fullname>PlayStation 3</fullname> \
    <path>'"$PS3_ROMS_DIR"'</path> \
    <extension>.sh .SH .iso .pkg .ps3 .7z .zip .rar .squashfs .m3u</extension> \
    <command>/opt/retropie/supplementary/runcommand/runcommand.sh 0 _SYS_ ps3 %ROM%</command> \
    <platform>ps3</platform> \
    <theme>ps3</theme> \
  </system>' "$ES_SYSTEMS_CFG"
                echo "New PS3 entry added to $ES_SYSTEMS_CFG"
            else
                echo "PS3 entry already exists in $ES_SYSTEMS_CFG"
            fi
        else
            echo "$ES_SYSTEMS_CFG not found, skipping modification."
        fi
    done
}

# Function to clear RPCS3 cache
function clear_rpcs3_cache() {
    local cache_dir="/home/pi/.cache/rpcs3/"

    # Check if the cache directory exists
    if [[ -d "$cache_dir" ]]; then
        # Use dialog to ask the user if they're sure
        dialog --title "Confirm Cache Deletion" --yesno "Are you sure you want to clear the contents of $cache_dir? This will clear all cache files and folders inside it, but not the main directories." 7 60
        response=$?

        if [[ $response -eq 0 ]]; then
            # Loop over the first-level directories inside the cache_dir
            for dir in "$cache_dir"/*; do
                if [[ -d "$dir" && "$dir" != "$cache_dir" ]]; then
                    # Remove all files inside the first-level subdirectories, except .log and .buf files
                    find "$dir" -maxdepth 1 -type f ! \( -name "*.log" -o -name "*.buf" \) -exec rm -f {} \;

                    # Truncate .log and .buf files to clear their contents
                    find "$dir" -maxdepth 1 -type f \( -name "*.log" -o -name "*.buf" \) -exec truncate -s 0 {} \;

                    # Remove any subdirectories inside the first-level subdirectory
                    find "$dir" -mindepth 1 -type d -exec rm -rf {} \;
                fi
            done

            # Notify the user that the cache has been cleared successfully
            dialog --title "Cache Cleared" --msgbox "Cache cleared successfully, but main directories are preserved." 6 60
        else
            # If the user canceled the operation
            dialog --title "Operation Canceled" --msgbox "Operation canceled. No changes were made to $cache_dir." 6 60
        fi
    else
        # If the cache directory doesn't exist
        dialog --title "Directory Not Found" --msgbox "RPCS3 cache directory does not exist. No action taken." 6 60
    fi
}

function clear_rpcs3_config() {
    local config_dir="/home/pi/.config/rpcs3"
    
    # Check if the config directory exists
    if [[ -d "$config_dir" ]]; then
        # Use dialog to ask the user if they're sure
        dialog --title "Confirm Deletion" --yesno "Do you want to remove the RPCS3 config directory ($config_dir)? This will delete all configurations and settings." 7 60
        response=$?

        if [[ $response -eq 0 ]]; then
            # If the user confirmed, delete the directory
            rm -rf "$config_dir"
            dialog --title "Deletion Successful" --msgbox "$config_dir has been deleted." 6 60
        else
            dialog --title "Operation Canceled" --msgbox "Operation canceled. $config_dir was not deleted." 6 60
        fi
    else
        dialog --title "Directory Not Found" --msgbox "RPCS3 config directory ($config_dir) does not exist. No action taken." 6 60
    fi
}

# Function to provide a GUI interface for RPCS3 options using dialog
function gui_rpcs3() {
    choice=$(dialog --title "RPCS3 Options" --menu "Choose an option" 15 60 3 \
        "1" "Clear RPCS3 Cache" \
        "2" "Clear RPCS3 Configs" \
        "3" "Cancel" 2>&1 >/dev/tty)

    case $choice in
        1)
            # Command to launch RPCS3 with GUI
            clear_rpcs3_cache
            ;;
        2)
            # Call the function to clear cache
            clear_rpcs3_config
            ;;
        3)
            echo "Operation canceled."
            ;;
        *)
            echo "Invalid option selected."
            ;;
    esac
}

# Function to configure RPCS3 emulator in RetroPie
function configure_rpcs3() {
    # Add RPCS3 to RetroPie system
	addEmulator "$md_id" "rpcs3" "ps3" "XINIT: /opt/retropie/emulators/rpcs3/rpcs3.sh %ROM%"
    addEmulator "$md_id" "rpcs3-wm" "ps3" "XINIT-WM: /opt/retropie/emulators/rpcs3/rpcs3.AppImage %ROM%"
	addEmulator "$md_id" "rpcs3-no-gui" "ps3" "XINIT-WM: /opt/retropie/emulators/rpcs3/rpcs3.AppImage --no-gui %ROM%"
	addEmulator "$md_id" "rpcs3-no-wm" "ps3" "XINIT: /opt/retropie/emulators/rpcs3/rpcs3.AppImage %ROM%"
	
    # Set RPCS3 as the default emulator for PS3
    if [[ $(cat /opt/retropie/configs/ps3/emulators.cfg | grep -q 'default =' ; echo $?) == '1' ]]; then
        echo 'default = "rpcs3"' >> /opt/retropie/configs/ps3/emulators.cfg
    fi
    sed -i 's/default\ =.*/default\ =\ "rpcs3"/g' /opt/retropie/configs/ps3/emulators.cfg	
	
	# Create the rpcs3.sh manually
    echo "Creating gamelist.xml..."
    if [[ ! -f "$md_inst/rpcs3.sh" ]]; then
        cat > "$md_inst/rpcs3.sh" <<EOF
#!/bin/bash
if [[ "\$1" == '' ]]; then
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/opt/retropie/emulators/rpcs3/rpcs3.AppImage
else
xset -dpms s off s noblank 
matchbox-window-manager -use_titlebar no & 
/opt/retropie/emulators/rpcs3/rpcs3.AppImage --no-gui "\$1"
fi
EOF
        echo "rpcs3.sh created at $md_inst"
    fi
	
    # Make sure the start script is executable
    chmod +x "$RPCS3_PATH/rpcs3.sh"		
}
