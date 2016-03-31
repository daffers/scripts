param([string]$targetDirectory="c:\bbs\",[bool]$debug=$False)

Function Get-EpisodeListings
{
	$url = "http://barbellshrugged.libsyn.com/rss"

	Write-Host "Downloading all Barbellshrugged from " $url 

	$client = new-object System.Net.WebClient
	$episodeListings = [xml]$client.DownloadString($url)

	$episodes = $episodeListings.SelectNodes("//item")

	Write-Host "found " $episodes.Count " epsiodes"

	return $episodes
} 

Function Try-WriteEpisode([string]$outputPath, [string]$sourceUrl)
{
	if (-Not (Test-Path $outputPath))
	{
		Write-Host "Downloading episode to " $outputPath
		#$response = Invoke-WebRequest -Uri $episodeUrl.url -OutFile $outputName
		"data" | Out-File $outputPath
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

	$numAtEndRegex = ".*? - (?<episodeNum>\d+)$"
	$numAtEndMatch = new-object System.Text.RegularExpressions.Regex ($numAtEndRegex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	$numAtStartRegex = "Episode (?<episodeNum>\d+).*?"
	$numAtStartMatch = new-object System.Text.RegularExpressions.Regex ($numAtStartRegex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	$numAtStartRegex2 = "^(?<episodeNum>\d+) ?-.*?"
	$numAtStartMatch2 = new-object System.Text.RegularExpressions.Regex ($numAtStartRegex2, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	$epAtTheEnd = ".*? -? ?EP ?(?<episodeNum>\d+)$"
	$epAtTheEnd = new-object System.Text.RegularExpressions.Regex ($epAtTheEnd, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	$episodeAtTheEnd = ".*?( -)? EPISODE (?<episodeNum>\d+)$"
	$episodeAtTheEndMatch = new-object System.Text.RegularExpressions.Regex ($episodeAtTheEnd, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
	
	$episodeInLink = "http://traffic.libsyn.com/barbellshrugged/(bs)?(?<episodeNum>\d+)itunes.mp3(?:\.m4a)?"
	$episodeInLinkMatch = new-object System.Text.RegularExpressions.Regex ($episodeInLink, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	BBS_Episode199_FINAL.mp3.m4a
	$episodeInLink2 = "http://traffic.libsyn.com/barbellshrugged/(_)?(BBS_)?Episode_?(?<episodeNum>\d+)(_audio(_)?only)?(_FINAL)?(_AudioOnly)?.mp3(?:\.m4a)?"
	$episodeInLinkMatch2 = new-object System.Text.RegularExpressions.Regex ($episodeInLink2, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
		
	$bestOfRegex = "The Best of.*?"
	$bestOfMatch = new-object System.Text.RegularExpressions.Regex ($bestOfRegex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	$interviewsRegex = "^BS INTER.*?\s-\sEP(?<episodeNum>\d+)\s(?<episodeName>.*?)$"
	$interiewsMatch = new-object System.Text.RegularExpressions.Regex ($interviewsRegex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	$flightRegex = "^http://traffic.libsyn.com/barbellshrugged/PLV(?<episodeNum>\d+)podcast.mp3$"
	$flightMatch = new-object System.Text.RegularExpressions.Regex ($flightRegex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	foreach ($episode in $episodes)
	{
		 $episodeName = $episode.SelectSingleNode('title').'#text'
		 $episodeUrl = $episode.SelectSingleNode('enclosure') | select url
        
		 $match = $numAtEndMatch.Match($episodeName)

		 if ($match.Success)
		 {
			$epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
			$fepNum = "{0:D3}" -f $epNum
			$cleanName = $episodeName -replace "\s-\s\d{3}", ""
			$cleanName = Filter-IllegalCharacters($cleanName)
			$outputPath = $targetDirectory + $fepNum + " - " + $cleanName + ".mp3"

		   Try-WriteEpisode($outputPath, $episodeUrl)

			continue;
		 }

		 $match = $numAtStartMatch.Match($episodeName)
     
		 If ($match.Success)
		 {
			$epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
			$fepNum = "{0:D3}" -f $epNum     
			$cleanName = $episodeName -replace "Episode\s\d+\s-\s", ""   		 
			$cleanName = Filter-IllegalCharacters($cleanName)
			$outputPath = $targetDirectory + $fepNum + " - " + $cleanName + ".mp3"
        		 		 
			Try-WriteEpisode($outputPath, $episodeUrl)

			continue;
		 }
     
		 $match = $numAtStartMatch2.Match($episodeName)
     
		 if ($match.Success)
		 {
			 $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
			 
			 $fepNum = "{0:D3}" -f $epNum	 
			 $cleanName = $episodeName -replace "\s-\sBarbell Shrugged (Podcast )?EPISODE \d{2}", ""  			 
			 $cleanName = $cleanName -replace "\d+-\s", ""  			 
			 $cleanName = $cleanName -replace "\d+\s-\s", ""  		 
			 $cleanName = Filter-IllegalCharacters($cleanName)
			 $outputPath = $targetDirectory + $fepNum + " - " + $cleanName + ".mp3"
		 
			Try-WriteEpisode($outputPath, $episodeUrl)

			continue;
		 }
     
		 $match = $epAtTheEnd.Match($episodeName)
     
		 if ($match.Success)
		 {
		    $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
		    $fepNum = "{0:D3}" -f $epNum
	 		$cleanName = Filter-IllegalCharacters($episodeName)
			$cleanName = $cleanName -replace "\s-\sEpisode\s\d{2,3}", ""
		    $outputPath = $targetDirectory + $fepNum + " - " + $cleanName + ".mp3"
			
			Try-WriteEpisode($outputPath, $episodeUrl)

		    continue;
		 }
     
		 $match = $episodeAtTheEndMatch.Match($episodeName)
     
		 if ($match.Success)
		 {
		    $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
		    $fepNum = "{0:D3}" -f $epNum
	 		$cleanName = Filter-IllegalCharacters($episodeName)
			 $cleanName = $cleanName -replace "\s-\sEPISODE\s\d{2,3}", ""
		    $outputPath = $targetDirectory + $fepNum + " - " + $cleanName + ".mp3"
			
			Try-WriteEpisode($outputPath, $episodeUrl)

		    continue;
		 }
     
     
		 $match = $episodeInLinkMatch.Match($episodeUrl.url)
     
		 if ($match.Success)
		 {
		    $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
		    $fepNum = "{0:D3}" -f $epNum
	 		$cleanName = Filter-IllegalCharacters($episodeName)
		    $outputPath = $targetDirectory + $fepNum + " - " + $cleanName + ".mp3"

			Try-WriteEpisode($outputPath, $episodeUrl)
		    
			 continue;
		 }
     
		 $match = $episodeInLinkMatch2.Match($episodeUrl.url)
     
		 if ($match.Success)
		 {
		    $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
		    $fepNum = "{0:D3}" -f $epNum
	 		$cleanName = Filter-IllegalCharacters($episodeName)
		    $outputPath = $targetDirectory + $fepNum + " - " + $cleanName + ".mp3"

			Try-WriteEpisode($outputPath, $episodeUrl)
		    
			 continue;
		 }
     
		 $match = $bestOfMatch.Match($episodeName)
     
		 if ($match.Success)
		 {
			 New-Item -Path $targetDirectory -Name "best of" -ItemType "directory" -Force | Out-Null

	 		$cleanName = Filter-IllegalCharacters($episodeName)
		    $outputPath = $targetDirectory + "best of\" + $cleanName + ".mp3"

			Try-WriteEpisode($outputPath, $episodeUrl)
		    
			 continue;
		 }
     
		 $match = $interiewsMatch.Match($episodeName)
     
		 if ($match.Success)
		 {
			 New-Item -Path $targetDirectory -Name "Interogation Series" -ItemType "directory" -Force | Out-Null
			 $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
		    $fepNum = "{0:D2}" -f $epNum
			 $subEpisodeName = $match.Groups["episodeName"]
	 		$cleanName = Filter-IllegalCharacters($subEpisodeName)
		    $outputPath = $targetDirectory + "Interogation Series\" + $fepNum + " - " + $cleanName + ".mp3"

			Try-WriteEpisode($outputPath, $episodeUrl)
		    
			 continue;
		 }
     
		 $match = $flightMatch.Match($episodeUrl.url)
     
		 if ($match.Success)
		 {
			 New-Item -Path $targetDirectory -Name "Flight" -ItemType "directory" -Force | Out-Null
			 $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
		    $fepNum = "{0:D2}" -f $epNum
	 		$cleanName = Filter-IllegalCharacters($episodeName)
		    $outputPath = $targetDirectory + "Flight\" + $fepNum + " - " + $cleanName + ".mp3"

			Try-WriteEpisode($outputPath, $episodeUrl)
		    
			 continue;
		 }

		Write-Host "Unable to Match " $episodeName
		New-Item -Path $targetDirectory -Name "Unmatched" -ItemType "directory" -Force | Out-Null

		$cleanName = Filter-IllegalCharacters($episodeName)
		$outputPath = $targetDirectory + "Unmatched\" + $cleanName + ".mp3"

		Try-WriteEpisode($outputPath, $episodeUrl)
	}
}

Update-Drive
