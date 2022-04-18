//Global AuDir settings#macro AUDIR_GLOBAL_MAX_NOISE			140	// The max total noise level allowed in the game

#macro AUDIR_MAX_NOISE_LEVEL				2000		// Max allowed noise level

#region //////// Default Values /////////////////////////
// Default SFX values
#macro AUDIR_DEFAULT_MAX_COUNT		5		// The max count if instances of the sfx that are allowed to play at the same time
#macro AUDIR_DEFAULT_PRIORITY				1		// Lower priorities are kept alive if budget is met, high values may be culled.
#macro AUDIR_DEFAULT_SOUND_COST		5		// The cost of playing the sound, representation of abstract noise level.
#macro AUDIR_DEFAULT_MAX_NOISE			80	// The max allowed current noise for the sfx to play.
#macro AUDIR_DEFAULT_MIN_DELTA			20	// Minimum amount of ms between triggering the sfx.

// Default Gain values
#macro AUDIR_DEFAULT_MASTER_GAIN		100		// Master Gain
#macro AUDIR_DEFAULT_MUSIC_GAIN			100		// Muisc Gain
#macro AUDIR_DEFAULT_SFX_GAIN					100		// Sound Effect Gain
#macro	AUDIR_DEFAULT_AMBIANCE_GAIN	100		// Ambient sound Gain

// Default Transition Times
#macro AUDIR_DEFAULT_AMBIANCE_TRANSITION	4000	// TIme to transition between ambiant sounds in ms
#macro AUDIR_DEFAULT_MUSIC_TRANSITION			4000	// TIme to transition between Music tracks in ms
#macro	AUDIR_DEFAULT_STEM_TRANSITION			2000	// Time to transition gain on stems in a music track.
#endregion

