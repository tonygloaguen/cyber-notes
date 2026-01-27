# Définir les chemins source et destination
$sourcePath1 = "C:\Users\Gloaguen\Desktop\"
$sourcePath2 = "C:\Users\Gloaguen\Documents\"
$destinationPath = "D:\\"

# Récupérer la liste de tous les fichiers dans le dossier source
$files1 = Get-ChildItem -Path $sourcePath1 -Recurse -File 
$files2 = Get-ChildItem -Path $sourcePath2 -Recurse -File 

foreach ($file in $files1) {
    # Construire le nouveau chemin de destination
    $destination = $destinationPath + $file.FullName.Substring($sourcePath1.length)
    
    try {
        # Copier le fichier vers la clé USB
        Copy-Item -Path $file.FullName -Destination $destination -Force
    }
    catch {
        Write-Error "Erreur lors de la copie du fichier : $_"
    }
}

foreach ($file in $files2) {
    # Construire le nouveau chemin de destination
    $destination = $destinationPath + $file.FullName.Substring($sourcePath2.length)
    
    try {
        # Copier le fichier vers la clé USB
        Copy-Item -Path $file.FullName -Destination $destination -Force
    }
    catch {
        Write-Error "Erreur lors de la copie du fichier : $_"
    }
}