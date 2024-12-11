#!/usr/bin/env bash
#SUPREME TEAM 

rp_module_id="rpcs3"
rp_module_desc="RPCS3 - PS3 Emulator (AppImage)"
rp_module_licence="RPCS3 https://rpcs3.net/terms"
rp_module_section="main"  # "emulators" section
rp_module_flags="!x86"  # Excludes x86 (only for ARM systems)

RPCS3_VERSION="v0.0.34-17173-68b7e597"
RPCS3_APPIMAGE_URL="https://github.com/RPCS3/rpcs3-binaries-linux-arm64/releases/download/build-68b7e5971d8e279d7d385b96b5aa2feebd220506/rpcs3-${RPCS3_VERSION}_linux_aarch64.AppImage"
RPCS3_APPIMAGE_NAME="rpcs3-${RPCS3_VERSION}_linux_aarch64.AppImage"
PS3_ROMS_DIR="/home/pi/RetroPie/roms/ps3"
RPCS3_ICON_URL="https://rpcs3.net/cdn/branding/core-color-png.png"
RPCS3_ICON_PATH="$md_inst/rpcs3.png"
RPCS3_BOXART_ICON_PATH="$PS3_ROMS_DIR/boxart/PS3.png"
RPCS3_MARQUEE_URL="https://rpcs3.net/cdn/branding/full-color-png.png"
RPCS3_MARQUEE_PATH="$PS3_ROMS_DIR/marquee/PS3.png"
PS3_FIRMWARE_URL="http://dus01.ps3.update.playstation.net/update/ps3/image/us/2024_0227_3694eb3fb8d9915c112e6ab41a60c69f/PS3UPDAT.PUP"
PS3_FIRMWARE_PATH="/home/pi/RetroPie/BIOS/ps3/PS3UPDAT.PUP"

# Function to handle dependencies
function depends_rpcs3() {
    getDepends libfuse2 libsdl2-dev libvulkan1
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

    # Set up the ROMs folder if not already set up
    echo "Creating the +Start RPCS3 script..."
    cat > "$PS3_ROMS_DIR/+Start RPCS3.sh" <<EOF
#!/bin/bash
"/opt/retropie/supplementary/runcommand/runcommand.sh" 0 _SYS_ "ps3" ""
EOF

    # Make sure the start script is executable
    chmod +x "$PS3_ROMS_DIR/+Start RPCS3.sh"

    # Ensure the file was created
    if [[ ! -f "$PS3_ROMS_DIR/+Start RPCS3.sh" ]]; then
        echo "Error: Failed to create +Start RPCS3.sh script in $PS3_ROMS_DIR"
        exit 1
    fi

    # Download the RPCS3 icon and place it in the AppImage directory
    echo "Downloading RPCS3 icon..."
    if [[ ! -f "$RPCS3_ICON_PATH" ]]; then
        wget -O "$RPCS3_ICON_PATH" "$RPCS3_ICON_URL" || { echo "Failed to download RPCS3 icon"; exit 1; }
        echo "RPCS3 icon downloaded to $RPCS3_ICON_PATH"
    fi

    # Copy the icon to the same directory as the AppImage for consistency
    if [[ ! -f "$md_inst/rpcs3-icon.png" ]]; then
        cp "$RPCS3_ICON_PATH" "$md_inst/rpcs3-icon.png" || { echo "Failed to copy RPCS3 icon to AppImage directory"; exit 1; }
        echo "RPCS3 icon copied to $md_inst as rpcs3-icon.png"
    fi

    # Manually copy the icon to the boxart directory
    echo "Copying RPCS3 icon to boxart directory..."
    if [[ ! -f "$RPCS3_BOXART_ICON_PATH" ]]; then
        cp "$RPCS3_ICON_PATH" "$RPCS3_BOXART_ICON_PATH" || { echo "Failed to copy RPCS3 icon to boxart directory"; exit 1; }
        echo "RPCS3 icon copied to boxart as $RPCS3_BOXART_ICON_PATH"
    fi

    # Download the marquee image and save it in the marquee directory
    echo "Downloading RPCS3 marquee image..."
    if [[ ! -f "$RPCS3_MARQUEE_PATH" ]]; then
        wget -O "$RPCS3_MARQUEE_PATH" "$RPCS3_MARQUEE_URL" || { echo "Failed to download RPCS3 marquee image"; exit 1; }
        echo "RPCS3 marquee image downloaded to $RPCS3_MARQUEE_PATH"
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
        <path>./+Start RPCS3.sh</path>
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

# Function to configure RPCS3 emulator in RetroPie
function configure_rpcs3() {
    # Add RPCS3 to RetroPie system
    addEmulator "$md_id" "rpcs3" "ps3" "XINIT-WM: /opt/retropie/emulators/rpcs3/rpcs3.AppImage %ROM%"
	addEmulator "$md_id" "rpcs3-no-gui" "ps3" "XINIT-WM: /opt/retropie/emulators/rpcs3/rpcs3.AppImage --no-gui %ROM%"
	addEmulator "$md_id" "rpcs3-no-wm" "ps3" "XINIT: /opt/retropie/emulators/rpcs3/rpcs3.AppImage %ROM%"
	
    # Set RPCS3 as the default emulator for PS3
    if [[ $(cat /opt/retropie/configs/ps3/emulators.cfg | grep -q 'default =' ; echo $?) == '1' ]]; then
        echo 'default = "rpcs3"' >> /opt/retropie/configs/ps3/emulators.cfg
    fi
    sed -i 's/default\ =.*/default\ =\ "rpcs3"/g' /opt/retropie/configs/ps3/emulators.cfg
}
