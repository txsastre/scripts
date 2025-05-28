#!/bin/bash

LOG="$HOME/net-virtualbox.log"
VBOXMANAGE=$(which VBoxManage)

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG"
}

log "▶️ Inicio del script"

# Buscar interfaz Ethernet con IP
eth_iface=$(ip -o -4 addr show | awk '$2 ~ /^e|^en|^eth/ {print $2}' | head -n1)

# Buscar interfaz Wi-Fi con IP si no hay Ethernet
if [ -z "$eth_iface" ]; then
    wifi_iface=$(ip -o -4 addr show | awk '$2 ~ /^w|^wl/ {print $2}' | head -n1)
else
    wifi_iface=""
fi

# Elegir interfaz final
iface=""
if [ -n "$eth_iface" ]; then
    iface="$eth_iface"
    log "✅ Interfaz Ethernet activa con IP: $iface"
elif [ -n "$wifi_iface" ]; then
    iface="$wifi_iface"
    log "✅ Interfaz Wi-Fi activa con IP: $iface"
else
    log "❌ No se encontró ninguna interfaz con IP"
    exit 1
fi

# Listar VMs
vms=$($VBOXMANAGE list vms | cut -d'"' -f2)

for vm in $vms; do
    log "🔍 Revisando VM: $vm"
    for i in {1..4}; do
        tipo=$($VBOXMANAGE showvminfo "$vm" --machinereadable | grep "^nic${i}=" | cut -d'=' -f2 | tr -d '"')
	if [ "$tipo" = "bridged" ]; then
	    current_iface=$($VBOXMANAGE showvminfo "$vm" --machinereadable | grep "^bridgeadapter$i=" | cut -d'=' -f2 | tr -d '"')
	    if [ "$current_iface" != "$iface" ]; then
	        log "🚀 NIC$i en modo bridged. Reconfigurando de '$current_iface' a '$iface'"
	        $VBOXMANAGE modifyvm "$vm" --bridgeadapter$i "$iface"
	    else
	        log "✅ NIC$i ya usa '$iface'. No se necesita cambio"
	    fi
	fi

    done
done

log "✅ Script finalizado correctamente."
