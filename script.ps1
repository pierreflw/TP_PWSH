$url = "https://randomuser.me/api/?results=10"
$response = Invoke-RestMethod -Method 'Get' -Uri $url

# importer le CSV
$csv = Import-Csv -Path "/Users/pfw/TP_PWSH/speakers.csv"


for($i = 0; $i -lt 10; $i++) {

    # récupére l'URL de la photo
    $imgUrl = $response.results[$i].picture.medium

    # récupére le nom de fichier dans la colonne "photo" du CSV
    $fileName = $csv[$i].photo   # par ex. "johndoe.jpg"

    # Construire le chemin complet
    $localPath = "/Users/pfw/TP_PWSH/photos/$fileName"

    # télécharge la photo sous ce nom
    Invoke-WebRequest -Uri $imgUrl -OutFile $localPath
}

# construit la collection d'objets
$data = $csv | ForEach-Object {
    [PSCustomObject]@{
        firstname    = $_.firstname
        lastname     = $_.lastname
        speciality   = $_.speciality
        age          = $_.age
        city         = $_.city
        photo        = $_.photo
        rgpd_consent = $_.rgpd_consent
        created_at   = $_.created_at
    }
}

# génère le bloc HTML pour chaque intervenant
$ficheHTML = $data | ForEach-Object {
    @"
<div class="fiche">
  <h2>$($_.firstname) $($_.lastname)</h2>
  <ul>
    <li>
      <img src="photos/$($_.photo)" alt="Photo de $($_.firstname)" />
    </li>
    <li><strong>Spécialité :</strong> $($_.speciality)</li>
    <li><strong>Âge :</strong> $($_.age)</li>
    <li><strong>Ville :</strong> $($_.city)</li>
    <li><strong>Chemin Photo :</strong> $($_.photo)</li>
    <li><strong>RGPD :</strong> $($_.rgpd_consent)</li>
    <li><strong>Créé le :</strong> $($_.created_at)</li>
  </ul>
</div>
"@
} | Out-String

# Style CSS de la page
$style = @"
<style>
  body {
    font-family: Arial, sans-serif;
    background-color: #FAFAFA;
  }
    h1 {
    text-align: center;
}
  .fiche {
    border: 2px solid #edecec;
    border-radius: 4px;
    padding: 1em;
    margin-bottom: 1em;
    width: 400px;
    margin: 1em auto;
    text-align: left;
  }
  .fiche h2 {
    background-color: #4CAF50;
    color: white;
    margin-top: 0;
    padding: 0.5em;
  }
  .fiche ul {
    list-style-type: none;
    padding: 0;
    margin: 0;
  }
  .fiche li {
    margin: 0.5em 0;
  }
</style>
"@

# assemble le HTML final
$htmlPage = @"
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>Intervenants</title>
  $style
</head>
<body>
  <h1>Liste des intervenants</h1>
  $ficheHTML
</body>
</html>
"@

# ecrit tout dans le fichier HTML
$htmlPage | Out-File "/Users/pfw/TP_PWSH/speakers.html"