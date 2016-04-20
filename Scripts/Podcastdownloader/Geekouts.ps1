param([string]$targetDirectory="C:\geekouts\",[bool]$debug=$True)

Function Get-EpisodeListings
{
	$url = "http://www.pwop.com/feed.aspx?show=dotnetrocks&filetype=master&tags=Geek%20Out"

	Write-Host "Downloading all Geekouts from " $url 

	$client = new-object System.Net.WebClient
	$episodeListings = [xml]$client.DownloadString($url)

	$episodes = $episodeListings.SelectNodes("//item")

	Write-Host "found " $episodes.Count " epsiodes"

	return $episodes
} 

Function Try-WriteEpisode($outputPath, $sourceUrl)
{
	if (-Not (Test-Path $outputPath))
	{
		Write-Host "Downloading episode from " $sourceUrl
		Write-Host "Downloading episode to " $outputPath
		Invoke-WebRequest -Uri $sourceUrl -OutFile $outputPath
		#sourceUrl | Out-File $outputPath
	}
	else
	{
		if ($debug)
		{
			Write-Host "file already exists. File name: " $outputPath
		}
	}
}

Function Filter-IllegalCharacters([string]$inputName)
{
	$cleanName = $inputName -replace "w/", "with "
	$cleanName = $cleanName -replace ":", ","
	$cleanName = $cleanName -replace """", "'"    	
	$cleanName = $cleanName -replace "&", "and"  
	$cleanName = $cleanName -replace "\?", ""  
	$cleanName = $cleanName -replace "\\", "-"  
	$cleanName = $cleanName -replace "/", "-"  
	$cleanName = $cleanName -replace "S\#\*T", "shit"  
	$cleanName = $cleanName -replace "\[", ""  
	$cleanName = $cleanName -replace "\]", ""  

	return $cleanName
}

Function Update-Drive
{
	[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null

	$episodes = Get-EpisodeListings

	$epNumRegex = "ShowNum=(?<episodeNum>\d+)$"
	$epNumMatch = new-object System.Text.RegularExpressions.Regex ($epNumRegex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
	
	foreach ($episode in $episodes)
	{
		$episodeName = $episode.SelectSingleNode('title').'#text'
		$url = $episode.SelectSingleNode('link').'#text' 
	
		$match = $epNumMatch.Match($url)

		$urlNode = $episode.SelectSingleNode('enclosure') 
		$episodeUrl = $urlNode.Attributes["url"].Value

		$epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
		$fepNum = "{0:D4}" -f $epNum
		$cleanName = Filter-IllegalCharacters($episodeName)
		$outputPath = $targetDirectory + $fepNum + " - " + $cleanName + ".mp3"

		Try-WriteEpisode $outputPath  $episodeUrl
	}
}

Update-Drive