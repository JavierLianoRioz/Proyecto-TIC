## 🚀 Pasos después de lanzar `iniciar-server-vm.ps1`

¡Ya casi terminas! Sigue estos **3 comandos esenciales** para completar la configuración de tu servidor:

```bash
# 1. Instala Java y rdiff-backup
sudo apt install default-jdk rdiff-backup -y

# 2. Descarga e instala el servidor de Minecraft
curl -sL https://github.com/oddlama/minecraft-server/raw/refs/heads/main/installer/bootstrap | sudo bash

# 3. Adjunta la consola del servidor
sudo minecraft-attach server
```

> 💡 **Tip:** Asegúrate de ejecutar estos comandos en la terminal de tu VM.

---
¡Listo! Tu servidor estará funcionando en minutos. 🎮✨