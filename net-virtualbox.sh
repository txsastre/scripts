#!/bin/bash

LOG="$HOME/net-virtualbox.log"
VBOXMANAGE=$(which VBoxManage)

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG"
}

log "▶ Inicio del script"

# Detectar interfaz activa (prioridad Ethernet)
iface=$(ip -o link show | awk -F': ' '/state UP/ {print $2}' | grep -E '^e|^en|^eth' | head -n1)

if [ -z "$iface" ]; then
    iface=$(ip -o link show | awk -F': ' '/state UP/ {print $2}' | grep -E '^w|^wl' | head -n1)
fi

if [ -z "$iface" ]; then
    log "❌ No se detectó ninguna interfaz de red activa"
    exit 1
else
    log "✅ Interfaz activa seleccionada: $iface"
fi

# Listar VMs de forma segura (manejando espacios)
$VBOXMANAGE list vms | while IFS= read -r line; do
    vm=$(echo "$line" | cut -d'"' -f2)
    log "🔍 Revisando VM: $vm"
    for i in {1..4}; do
        # Obtener tipo de conexión y adaptador actual
        tipo=$($VBOXMANAGE showvminfo "$vm" --machinereadable | grep "^nic${i}=" | cut -d'=' -f2 | tr -d '"')
        adapter=$($VBOXMANAGE showvminfo "$vm" --machinereadable | grep "^bridgeadapter${i}=" | cut -d'=' -f2 | tr -d '"')
        
        if [ "$tipo" = "bridged" ]; then
            if [ "$adapter" != "$iface" ]; then
                notify-send "🔧 NIC$i en modo bridged. Reconfigurando con '$iface'"
                log "🔧 NIC$i en modo bridged. Adaptador actual: '$adapter'. Reconfigurando con '$iface'"
                $VBOXMANAGE modifyvm "$vm" --bridgeadapter$i "$iface"
            else
                log "ℹ️ NIC$i ya está configurado correctamente con '$iface'"
            fi
        fi
    done
done

notify-send "VB - Canvi xarxa - Finalitzat"
log "VB - Canvi Xarxa - Finalitzat"
