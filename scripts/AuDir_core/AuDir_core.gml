
/// @func		audir_create_sfx( sound_array, critical)
/// @arg			sfx_name				Name of the SFX.
/// @arg			sound_array			An array of sound files that is accociated with the sfx
/// @arg			critical					A boolean representing if the soun should always play even if budget is max
function audir_create_sfx(_sfx_name, _sound_array, _critical = false){
	if not ds_map_exists(o_audir._audir_sfx_maintainer, _sfx_name){ // Check if name is not in use
		o_audir._audir_sfx_maintainer[? _sfx_name] = { // SFX struct with data
			sound_array				:		_sound_array,
			critical							:		_critical,
			max_count					:		AUDIR_DEFAULT_MAX_COUNT,
			priority							:		AUDIR_DEFAULT_PRIORITY,
			sound_cost					:		AUDIR_DEFAULT_SOUND_COST,
			min_delta					:		AUDIR_DEFAULT_MIN_DELTA,
			max_noise					:		AUDIR_DEFAULT_MAX_NOISE,
			last_played_id			:		ds_list_create(),
			last_played_name	:		ds_list_create(),
			last_time						:		0
		}
		return 1;
	} else { 
		return -1; // SFX name already in use
	}
}

/// @func		audir_create_sfx_ext( sound_array, critical, max_count, priority, sound_cost, min_delta, max_noise)
/// @arg			sfx_name				Name of the SFX.
/// @arg			sound_array			An array of sound files that is accociated with the sfx
/// @arg			critical					A boolean representing if the soun should always play even if budget is max
/// @arg			max_count			Max count if instances of the sfx that are allowed to play at the same time
/// @arg			priority					Lower priorities are kept alive if budget is met, high values may be culled.
/// @arg			sound_cost			Cost of playing the sound, representation of abstract noise level.
/// @arg			min_delta				Minimum amount of ms between triggering the sfx.
/// @arg			max_noise			Max allowed current noise for the sfx to play.
function audir_create_sfx_ext(_sfx_name, _sound_array, _critical = false, _max_count = AUDIR_DEFAULT_MAX_COUNT, _priority = AUDIR_DEFAULT_PRIORITY, _sound_cost = AUDIR_DEFAULT_SOUND_COST, _min_delta = AUDIR_DEFAULT_MIN_DELTA,  _max_noise = AUDIR_DEFAULT_MAX_NOISE){
	if not ds_map_exists(o_audir._audir_sfx_maintainer, _sfx_name){ // Check if name is not in use
		o_audir._audir_sfx_maintainer[? _sfx_name] = { // SFX struct with data
			sound_array				:	_sound_array,
			critical							:	_critical,
			max_count					:	_max_count,
			priority							:	_priority,
			sound_cost					:	_sound_cost,
			min_delta					:	_min_delta,
			max_noise					:	 _max_noise,
			last_played_id			:	ds_list_create(),
			last_played_name	:	ds_list_create(),
			last_time						:	0
		}
		return 1;
	} else { 
		return -1; // SFX name already in use
	}
}


/// @func	audir_get_sfx_active(sfx_id)
///@arg		sfx_name		The id of the sfx, typically a string or number.
/// @desc	Returns the number of currently playing instances of a sound.
function audir_sfx_is_playing(_sfx_id){
	var _sfx = o_audir._audir_sfx_maintainer[? _sfx_id];
	var _last_played_len = ds_list_size(_sfx.last_played_id);
	var return_val = 0, _i = 0;
	while (_i < _last_played_len && audio_is_playing(_sfx.last_played_id[| _last_played_len - _i])){
		return_val += 1;
		_i += 1;
	}
	return return_val;
}



/// @func audir_create_music_track(music_track_name, stem_array, music_mood_struct)
function audir_create_music_track(_music_track_name, _stem_array, _music_mood_struct) {
	/* Example code
	audir_create_music_track( "forest_level_music", [snd_forest_level_0, snd_forest_level_1, snd_forest_level_2], 
	{	default_mood:	[1.0, 0.0, 0.0],
		danger:				[1.0, 1.0, 0.0],
		battle:				[1.0, 1.0, 1.0] })
*/
	return -1	
	// TODO
}


/// @func		audir_instance_init()
/// @desc		Initializes an instance to be used with AuDir
function audir_instance_init() {
	if not variable_instance_exists(self, "_audir_emitter"){
		_audir_emitter = audio_emitter_create();
		ds_map_add( o_audir._audir_emitter_maintainer, self, _audir_emitter);
		return 1;
	} else {
		return -1; // Audir Emitter already exists for this instance	
	}
}


/// @func		audir_instance_cleanup()
/// @desc		Cleans up datastructures and emitters used by the instance, call before instance destroy or in clean up event
function audir_instance_cleanup() {
	var _is_in_map = ds_map_find_value(o_audir._audir_emitter_maintainer, self);
	if (_is_in_map != -1){
		ds_map_delete(o_audir._audir_emitter_maintainer, self);	
	}
	variable_instance_exists(self, "_audir_emitter");
	audio_emitter_free(_audir_emitter);
	return -1
}


/// @func	audir_init()
/// @desc	Initializes an instance of the audir object
function audir_init(){
	var static _audir_ref = instance_create_depth(0, 0, 0, o_audir); 
	return _audir_ref;
}


/// @func	audir_play_sfx(sfx_name)
/// @desc	Plays Audir SFX from the instance that calls the function
/// @arg		sfx_name		The name of the sfx that should be played.
function audir_play_sfx(_sfx_name){
	var _sfx = o_audir._audir_sfx_maintainer[? _sfx_name];
	var _is_too_noisy							= ((o_audir._audir_current_noise_level > AUDIR_MAX_NOISE_LEVEL) or (_sfx.max_noise > AUDIR_MAX_NOISE_LEVEL));																						// would Noise Budget be exeeded if sfx is played?
	var _enough_time_has_passed	= ( current_time - _sfx.last_played	> _sfx.min_delta )	// Has enough time passed since last time the sfx was played?
	var _is_sfx_critical							= _sfx.critical;																			// Is the SFX critical, aka should play no matter what?
	
	if ( _is_sfx_critical or (!_is_too_noisy and _enough_time_has_passed) ){
			//Play the sound
			
			//blip blop missing code
			return 1 // Sound played sucessfully
	} 
	return -1	// Could not play sound
}


/// @func				audir_set_master_gain(gain)
/// @desc				Set the Master gain in the Game
/// @arg		gain	The value to set the gain to. [0 - 100]
function audir_set_master_gain(_gain) {
	o_audir._audir_master_gain = _gain;
}


/// @func				audir_set_music_gain(gain)
/// @desc				Set the gain of the Music in the Game
/// @arg		gain	The value to set the gain to. [0 - 100]
function audir_set_music_gain(_gain) {
	o_audir._audir_music_gain = _gain;
}


/// @func				audir_set_sfx_gain(gain)
/// @desc				Set the gain of the SFX in the Game
/// @arg		gain	The value to set the gain to. [0 - 100]
function audir_set_sfx_gain(_gain) {
	o_audir._audir_sfx_gain = _gain;	
}


/// @func				audir_set_ambiance_gain(gain)
/// @desc				Set the gain of the Ambiance in the Game
/// @arg		gain	The value to set the gain to. [0 - 100]
function audir_set_ambiance_gain(_gain) {
	o_audir._audir_ambiance_gain = _gain;	
}

