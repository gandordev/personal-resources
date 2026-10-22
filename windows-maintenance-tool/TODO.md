0\. Opciones de energía: maximo rendimiento

 	powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

 	powercfg -s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c



1\. Mejorar wifi para juegos competitivos

 	- https://www.youtube.com/shorts/H2GbJJwy6lg?feature=share

 	- https://www.youtube.com/shorts/L\_Osx4pd3s8?feature=share



3\. Editor de Registro (Regedit) y eliminamos esta restricción de raíz.

Ruta clave: HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile

Valor a modificar: NetworkThrottlingIndex

El fix: Cambiar el valor decimal por el hexadecimal FFFFFFFF.



4\. Agregar "Finalizar Tarea" en la taskbar para las apps



5\. Menu contextual original windows

 	reg.exe add "HKCU\\Software\\Classes\\CLSID\\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\\InprocServer32" /f /ve



 	taskkill -IM explorer.exe -f



 	explorer.exe



6\. Instalar apps

 	- brave

 	- notepad++

 	- epic games

 	- steam

 	- revouninstaller

 	- discord

 	- whatsapp

 	- spotify

 	- everything

 	- git

