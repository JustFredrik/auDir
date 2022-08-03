<p align="center"><img src="https://raw.githubusercontent.com/JustFredrik/auDir/main/auDir_logo.png" style="display:block; margin:auto; width:400px"></p>
<h2 align="center">Version 0.1</h2>
<p align="center">(work in progress / pre-release)</p>

&nbsp; 
<p align="justify"> auDir is a free audio management library for GameMaker 2022.6+ by <a href="https://twitter.com/JstFredrik"><b>@JustFredrik</b></a>. The library inteads to straemline SFX- and music management. The goal with auDir is to aid developers in managing and mainting emitters, audio groups and making all things audio easy to perform.</p>
<h2>Quick Overview</h2>
<h3>Audio Types</h3>
<p align="justify">auDir at it's core has three different types of audio resources: SFX, ambiance and music. These abstract audio types can be declared at any point and works to simplify the amount of code that needs to be written to perform common audio tasks. sound effects (SFX) can contain multiple sound resources and audir will pseudo-randomly select different sounds each time and slightly pitch shift it when an sfx is played to avoid repetetiveness. Ambiance and music-tracks can be queued, controlled and smoothly transitioned between different tracks with minimal code. Music tracks can have multiple stems which can fade in and out dynamically depending on the state of the game.
  
auDir keeps track of active sounds and emitters and will work ontop of GameMakers audio engine and aids in making sure the sound is clear and does not get overwhelming or muddled. auDir also has an audio group manager which can load and deload audio groups dynamically with some pre-configuration required.</p>
<p>(For more information see the <a href="https://github.com/JustFredrik/auDir/wiki">wiki</a>)</p>

Click HERE for the latest release
<h1 align="left"></h1>
