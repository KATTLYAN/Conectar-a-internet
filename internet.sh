#!/bin/bash

verrinterfaces() {
    echo -e "\nInterfaces disponibles: "
    ip -br link show | awk '{print $1, $2}'
}

listas_de_redes() {
    read -p "\nIngrese la interfaz: " wifi_iface
    sudo iw dev "$wifi_iface" scan | grep SSID
}

conectar() {
    read -p "\nIngrese la interfaz Wifi: " wifi_iface
    read -p "\nIngrese el nombre de la red: " ssid
    read -sp "\nIngrese la contraseña (dejar vacío en caso de que sea una red abierta): " password
    echo

    if [ -z "$password" ]; then
        nmcli dev wifi connect "$ssid" ifname "$wifi_iface"
    else
        nmcli dev wifi connect "$ssid" password "$password" ifname "$wifi_iface"
    fi
}

cambiar_estado_de_interfaz() {
    read -p "\nIngrese la interfaz a modificar: " interfaz
    read -p "\nIngrese el estado (up/down): " estado
    sudo ip link set "$interfaz" "$estado" && echo "Interfaz $interfaz establecida en $estado."
}

configurar_red() {
    read -p "\nIngresar interfaz a configurar: " interfaz
    read -p "\nConfiguración dinámica o estática [dhcp/estatica]: " tipo_config
    
    if [ "$tipo_config" == "dhcp" ]; then
        sudo nmcli con mod "$interfaz" ipv4.method auto
        sudo nmcli con up "$interfaz"
        echo "\nConfiguración establecida con DHCP."
    else
        read -p "\nIngrese la dirección IP: " ip
        read -p "\nIngrese la máscara de red: " mascara
        read -p "\nIngrese la puerta de enlace: " gateway
        
        sudo nmcli con mod "$interfaz" ipv4.address "$ip/$mascara"
        sudo nmcli con mod "$interfaz" ipv4.gateway "$gateway"
        sudo nmcli con mod "$interfaz" ipv4.method manual
        sudo nmcli con up "$interfaz"
        
        echo "Configuración estática aplicada"
    fi
}

while true; do
    echo -e "\n\n--- Configuración de red ---"
    echo "1. Mostrar interfaces de red"
    echo "2. Listar redes Wifi disponibles"
    echo "3. Conectarse a Wifi"
    echo "4. Cambiar estado de interfaz (necesita sudo)"
    echo "5. Configurar red"
    echo "6. Salir"
    
    read -p "Seleccione una opción: " opcion
    
    case $opcion in
        1) verrinterfaces ;;
        2) listas_de_redes ;;
        3) conectar ;;
        4) cambiar_estado_de_interfaz ;;
        5) configurar_red ;;
        6) exit 0 ;;
        *) echo "Opción no válida" ;;
    esac

done
