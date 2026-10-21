Scripts para agregar, eliminar y listar alias personalizados en Linux y Windows.


* `linux/` → scripts Bash para Linux/macOS.
* `windows/` → scripts PowerShell para Windows.
* `utils/common.sh` → funciones comunes para Linux (manejo de `.bashrc`).



### **Notas importantes**

- En Linux, `.bashrc` se respalda automáticamente antes de modificaciones (`.bak`).  
- En Windows, modifica el `$PROFILE` de PowerShell.  
- Todos los scripts verifican existencia y ofrecen actualización opcional.  
- Separación clara de funciones reutilizables (`common.sh`) y scripts principales.  
- Scripts son totalmente compatibles con Bash moderno y PowerShell 5+.  

