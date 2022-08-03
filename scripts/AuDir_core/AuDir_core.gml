/*---------------------------------------------------------------------------------------


         .8.         8 8888      888   8 888888888o.       , 888.   8 8888888888o.   
        .888.        8 8888      888   8 8888    `^888.    8 8888   8 8888    `8888.  
       :88888.       8 8888      888   8 8888      `888.   ` 888'   8 8888     `8888  
      . `88888.      8 8888      888   8 8888       `888,           8 8888     ,8888  
     .8. `88888.     8 8888      888   8 8888        8888  8 8888   8 8888    ,8888'  
    .8`8. `88888.    8 8888      888   8 8888        8888  8 8888   8 8888  ,888P'   
   .8' `8. `88888.   8 8888      888   8 8888       ,888'  8 8888   8 8888  88b       
  .8'   `8. `88888.  `8 888      88P   8 8888      ,888'   8 8888   8 8888   888b.     
 .8'     `8. `88888.   8 888    ,88P   8 8888    ,o88P'    8 8888   8 8888   `8888b.   
.8'       `8. `88888.   '8`Y88888P'    8 888888888P'       8 8888   8 8888    `88888. 

					Audio Management Library for GameMaker
								Version 0.2

				Author:		Fredrik "JustFredrik" Svanholm
				Twitter:	http://www.twitter.com/jstfredrik
				Github:		https://github.com/JustFredrik/auDir

-----------------------------------------------------------------------------------------
*/

#region Init and Cleanup


/// @func	audir_init()
/// @desc	Initializes an instance of the audir object
function audir_init(){
	var static _audir_ref = instance_create_depth(0, 0, 0, o_audir); 
	return _audir_ref;
}


/// @func	audir_instance_init()
/// @desc	Initializes an instance to be used with AuDir
function audir_instance_init() {
	if not variable_instance_exists(self, "_audir_emitter"){
		_audir_emitter = audio_emitter_create();
		ds_map_add( o_audir._audir_emitter_maintainer, self, _audir_emitter);
		return 1;
	} else {
		return -1; // Audir Emitter already exists for this instance	
	}
}


/// @func	audir_instance_cleanup()
/// @desc	Cleans up datastructures and emitters used by the instance, call before instance destroy or in clean up event
function audir_instance_cleanup() {
	var _is_in_map = ds_map_find_value(o_audir._audir_emitter_maintainer, self);
	if (_is_in_map != -1){
		ds_map_delete(o_audir._audir_emitter_maintainer, self);	
	}
	variable_instance_exists(self, "_audir_emitter");
	audio_emitter_free(_audir_emitter);
	return -1
}

#endregion
//-------------------------------------
#region SFX


/// @func					audir_create_sfx( sound_array, critical, max_count, priority, sound_cost, min_delta, max_noise)
/// @arg	sfx_name		Name of the SFX.
/// @arg	sound_array		An array of sound files that is accociated with the sfx
/// @arg	critical		A boolean representing if the soun should always play even if budget is max
/// @arg	sfx_group		Tag for which sfx group that the sfx belongs to.
/// @arg	max_count		Max count if instances of the sfx that are allowed to play at the same time
/// @arg	priority		Lower priorities are kept alive if budget is met, high values may be culled.
/// @arg	sound_cost		Cost of playing the sound, representation of abstract noise level.
/// @arg	min_delta		Minimum amount of ms between triggering the sfx.
/// @arg	pitch_delta		The amount a SFX can vary in pitch.
/// @arg	max_noise		Max allowed current noise for the sfx to play.
function audir_create_sfx(_sfx_name, _sound_array, _critical = false, 
_sfx_group = AUDIR_DEFAULT_SFX_GROUP, _max_count = AUDIR_DEFAULT_MAX_COUNT, 
_priority = AUDIR_DEFAULT_PRIORITY, _sound_cost = AUDIR_DEFAULT_SOUND_COST, 
_min_delta = AUDIR_DEFAULT_MIN_DELTA,  _pitch_delta = AUDIR_DEFAULT_PITCH_DELTA, 
_max_noise = AUDIR_DEFAULT_MAX_NOISE)
{
	if not ds_map_exists(o_audir._audir_sfx_maintainer, _sfx_name){ // Check if name is not in use
		o_audir._audir_sfx_maintainer[? _sfx_name] = { // SFX struct with data
			sound_array			:	_sound_array,
			critical			:	_critical,
			sfx_group			:	_sfx_group,
			max_count			:	_max_count,
			priority			:	_priority,
			sound_cost			:	_sound_cost,
			min_delta			:	_min_delta,
			pitch_delta			:	_pitch_delta,
			max_noise			:	_max_noise,
			last_played_id		:	ds_list_create(),
			last_played_name	:	ds_list_create(),
			last_time			:	0
		}
		return 1;
	} else { 
		return -1; // SFX name already in use
	}
}


/// @func				audir_create_sfx_group( sfx_group, gain)
/// @arg	sfx_group	The name/id for the new SFX group
/// @arg	gain		The Initial gain for the SFX group
function audir_create_sfx_group(_sfx_group_name, _gain = AUDIR_DEFAULT_SFX_GAIN){
	if (!ds_map_exists(o_audir._audir_sfx_groups, _sfx_group_name)){
		o_audir._audir_sfx_groups[? _sfx_group_name] = {
			gain	:	_gain
		};
		return 1 // Group was created
	} else {
		return -1 // Group already exists
	}
}


/// @func				audir_get_sfx_active(sfx_id)
/// @arg	sfx_name	The id of the sfx, typically a string or number.
/// @desc				Returns the number of currently playing instances of a sound.
function audir_sfx_is_playing(_sfx_id){
	var _sfx = o_audir._audir_sfx_maintainer[? _sfx_id];
	var _last_played_len = ds_list_size(_sfx.last_played_id);
	var return_val = 0, _i = 0;
	
	while (_i < _last_played_len){
		return_val += audio_is_playing(_sfx.last_played_id[| _i]);
		_i += 1;
	}
	return return_val;
}


/// @func				audir_play_sfx(sfx_name)
/// @desc				Plays Audir SFX from the instance that calls the function
/// @arg	sfx_name	The name of the sfx that should be played.
/// @arg	instance	Instance where it should be played
function audir_play_sfx(_sfx_name, _instance = id){
	var _sfx = o_audir._audir_sfx_maintainer[? _sfx_name];
	var _is_too_noisy = ((o_audir._audir_current_noise_level > AUDIR_MAX_NOISE_LEVEL) or (o_audir._audir_current_noise_level > _sfx.max_noise));																						// would Noise Budget be exeeded if sfx is played?
	var _enough_time_has_passed	= ( current_time - _sfx.last_time	> _sfx.min_delta )	// Has enough time passed since last time the sfx was played?
	var _is_sfx_critical = _sfx.critical;	// Is the SFX critical, aka should play no matter what?
	
	if ( _is_sfx_critical or (!_is_too_noisy and _enough_time_has_passed) ){
			//Select appropriate sound to play
			var _okay_snd = false;
			var _snd, _i, _long_ago_limit;
			
			while (!_okay_snd){ // Check if it has recently been played
				_okay_snd = true;
				_snd = _sfx.sound_array[irandom(array_length(_sfx.sound_array)-1)];
				_i = 0;
				_long_ago_limit = floor(sqrt(array_length(_sfx.sound_array)));
				while (_i < _long_ago_limit){
					if (_long_ago_limit <= 1){
						break
					}
					if (_snd == _sfx.last_played_name[| _i]){
						_okay_snd = false;
						break
					}
					_i += 1;
				}
				//if (_snd == _sfx.last_played_name[| 0]){ _okay_snd = false; } // Just a safe check
			}
			// Cull tracking list
			while(ds_list_size(_sfx.last_played_id) > _long_ago_limit) && !audio_is_playing(_sfx.last_played_id[| _long_ago_limit]){
					ds_list_delete(_sfx.last_played_id,		_long_ago_limit);
					ds_list_delete(_sfx.last_played_name,	_long_ago_limit);
			}
			
			//Play the sound
			var _snd_id = audio_play_sound_on(_instance._audir_emitter, _snd, false, _sfx.priority);
			_sfx.last_time = current_time;
			
			// Set pitch and set volume of sound 
			var _gain = audir_get_sfx_group_gain(_sfx.sfx_group) * audir_get_sfx_gain();
			audio_sound_gain(_snd_id, _gain, 0);
			audio_sound_pitch(_snd_id, random_range(1 - _sfx.pitch_delta, 1 + _sfx.pitch_delta));
			
			// Store sound in tracking lists
			ds_list_insert(_sfx.last_played_id,		0, _snd_id);
			ds_list_insert(_sfx.last_played_name,	0, _snd);
			
			// Add sound to AuDir queue
			__audir_add_sfx_to_queue(_snd_id, _snd, _sfx_name, _sfx.priority, _sfx.sound_cost);
			o_audir._audir_current_noise_level += _sfx.sound_cost;
			
			return 1 // Sound played sucessfully
	} 
	return -1	// Could not play sound
}


function audir_stop_sfx_group(_group_name){
	// TODO
	return -1	
}
	
	
function audir_pause_sfx_group(_group_name){
	// TODO
	return -1
}


function audir_resume_sfx_group(_group_name){
	// TODO
	return -1
}


function audir_update_sfx_gains(){
	// TODO	
}


#endregion
#region Music

/// @func audir_create_music_track(music_track_name, stem_array, music_mood_struct)
function audir_create_music_track(_music_track_name, _stem_array, _music_mood_struct) {
	/* Example code
	audir_create_music_track( "forest_level_music", [snd_forest_level_0, snd_forest_level_1, snd_forest_level_2], 
	{	default_mood:	[1.0, 0.0, 0.0],
		danger:			[1.0, 1.0, 0.0],
		battle:			[1.0, 1.0, 1.0] })
*/
	return -1	
	// TODO
}

#endregion
#region Ambiance
#endregion
//-------------------------------------
#region Setters
/// @func			audir_set_master_gain(gain)
/// @desc			Set the Master gain in the Game
/// @arg	gain	The value to set the gain to. [0 - 100]
function audir_set_master_gain(_gain) {
	o_audir._audir_master_gain = _gain;
}


/// @func			audir_set_music_gain(gain)
/// @desc			Set the gain of the Music in the Game
/// @arg	gain	The value to set the gain to. [0 - 100]
function audir_set_music_gain(_gain) {
	o_audir._audir_music_gain = _gain;
}


/// @func			audir_set_sfx_gain(gain)
/// @desc			Set the gain of the SFX in the Game
/// @arg	gain	The value to set the gain to. [0 - 100]
function audir_set_sfx_gain(_gain) {
	o_audir._audir_sfx_gain = _gain;	
}


/// @func				audir_set_sfx_group_gain(sfx_group, gain)
/// @desc				Set the gain of the SFX in the Game
/// @arg	sfx_group	The Group that you wish to change gain on
/// @arg	gain		The value to set the gain to. [0 - 100]
function audir_set_sfx_group_gain(_sfx_group, _gain) {
	if ds_map_exists(o_audir._audir_sfx_groups, _sfx_group){
		o_audir._audir_sfx_groups[? _sfx_group].gain = _gain;	
	}
}


/// @func			audir_set_ambiance_gain(gain)
/// @desc			Set the gain of the Ambiance in the Game
/// @arg	gain	The value to set the gain to. [0 - 100]
function audir_set_ambiance_gain(_gain) {
	o_audir._audir_ambiance_gain = _gain;
}


#endregion
#region Getters

/// @func			audir_get_master_gain()
/// @desc			Get the Master gain in the Game
function audir_get_master_gain() {
	return o_audir._audir_master_gain;
}


/// @func			audir_get_music_gain()
/// @desc			Get the gain of the Music in the Game
function audir_get_music_gain() {
	return o_audir._audir_music_gain;
}


/// @func			audir_get_sfx_gain()
/// @desc			Get the gain of the SFX in the Game
function audir_get_sfx_gain() {
	return o_audir._audir_sfx_gain;	
}

/// @func					audir_get_sfx_group_gain( group_name )
/// @arg	group_name		group_name or array with group_names of sfx groups to check
function audir_get_sfx_group_gain(_group_name){

	if is_array(_group_name){
		// TODO :: Add support for multiplication of multiple SFX groups in array
		__audir_show_warning_message("No current support for multiple SFX groups")
		return AUDIR_DEFAULT_SFX_GAIN;		
	} else { // Just one SFX group
		if (ds_map_exists(o_audir._audir_sfx_groups, _group_name)){	
		
			return o_audir._audir_sfx_groups[? _group_name].gain;
		} else {
			__audir_show_warning_message(string(_group_name) + ", No such SFX Group Exists")
			return AUDIR_DEFAULT_SFX_GAIN;
		}
	}
}


/// @func			audir_get_ambiance_gain()
/// @desc			Get the gain of the Ambiance in the Game
function audir_get_ambiance_gain() {
	return o_audir._audir_ambiance_gain;	
}


/// @func			audir_get_noise_level()
/// @desc			Gets the current noise level in the game
function audir_get_noise_level(){
	return o_audir._audir_current_noise_level;	
}


/// @func			audir_get_noise_level()
/// @desc			Gets the current noise level in the game
function audir_get_active_sfx_count(){
	return o_audir._audir_sound_queue.len;	
}


#endregion
//-------------------------------------
#region Audio Group Manager

/// @func						audir_define_audio_group_sounds(audiogroup_data)
/// @arg	audiogroup_data		Big struct with all the data
function audir_define_audio_group_sounds(_audiogroup_data){
	// TODO
	return -1
}


/// @func				audir_sound_get_audio:group(sound_id)
/// @arg	sound_id	Sound id for sound to check
function audir_sound_get_audio_group(_sound_id){
	// TODO
	return -1	
}


/// @func					audir_audio_group_load(audio_group)
/// @arg	audio_group_id	ID of audio group to load
function audir_audio_group_load(_audio_group_id){
	// TODO
	return -1	
}


/// @func					audir_audio_group_deload(audio_group_id)
/// @arg	audio_group_id	ID of audio group to deload
function audir_audio_group_deload(_audio_group_id){
	// TODO
	return -1
}


/// @func					audir_audio_group_set_persistent(audio_group_id, bool)
/// @arg	audio_group_id	id of audio group to set as persistent
/// @arg	bool			True or False flag to change the status
function audir_audio_group_set_persistent(_audio_group_id, _bool){
	// TODO
	return -1
}


#endregion
#region Internal / Helper functions

/// @func			__audir_show_warning_message(string)
/// @arg	string	string to show in the message
function __audir_show_warning_message(_warning_string){
	show_debug_message("[ AuDir ] WARNING : " + _warning_string);	
}


/// @func				__audir_get_queue_node(sound_id)
/// @arg	sound_id	Retrieves the node that holds the given sound_id
function __audir_get_queue_node(_sound_id){
	if ds_map_exists(o_audir._audir_sound_queue.map, _sound_id){
		return o_audir._audir_sound_queue.map[? _sound_id];	
	} else {
		return noone;	
	}
}


/// @func				__audir_add_sfx_to_queue(sound_id, sound_name, sfx_name, priority, noise)
/// @arg	sound_id	Sound id of the sound resource
/// @arg	sound_name	name of the sound resource
/// @arg	sfx_name	priority
/// @arg	noise		Noise value for the sfx
function __audir_add_sfx_to_queue(_sound_id, _sound_name, _sfx_name, _priority, _noise){
	var _queue	= o_audir._audir_sound_queue;
	var _snd_data = {
		sound_id	: _sound_id,
		sound_name	: _sound_name,
		sfx_name	: _sfx_name,
		priority	: _priority,
		noise		: _noise,
		previous	: noone,
		next		: noone
	}
	
	if (__audir_get_queue_node(_queue.first) == noone){
		_queue.first = _snd_data.sound_id;
		_queue.last  = _snd_data.sound_id;
	} else {
		var _node = __audir_get_queue_node(_queue.first);
		var _prev_node = _node;
		var _tmp_node;
		
		while(__audir_get_queue_node(_node.next) != noone){ // Find position to insert sound at
			if (_priority < _node.priority){ break } else {
				_prev_node = _node;
				_node = __audir_get_queue_node(_node.next);
			}
		}
		
		// Insert Sound data into queue
		_prev_node = __audir_get_queue_node(_node.previous);
		var _next_node = __audir_get_queue_node(_node.next);
			
		if (_priority < _node.priority ){
			if (_prev_node == noone) {
				_queue.first = _snd_data.sound_id;
			} else {
				_tmp_node = _prev_node;
				_tmp_node.next = _snd_data.sound_id;
			}
			_node.previous = _snd_data.sound_id;
			_snd_data.next = _node.sound_id;
		
		} else {
			if (_next_node == noone) {
				_queue.last = _snd_data.sound_id;	
			} else {
				_tmp_node = _next_node;
				_tmp_node.previous = _snd_data.sound_id;
			}
			_node.next = _snd_data.sound_id;
			_snd_data.previous = _node.sound_id;
		}
	}
	ds_map_add(o_audir._audir_sound_queue.map, _snd_data.sound_id, _snd_data);
	o_audir._audir_sound_queue.len += 1;
}


/// @func				__audir_remove_sfx_from_queue(node)
/// @arg	node		Node to remove from SFX queue
function __audir_remove_sfx_from_queue(_node){
	if (!ds_map_exists(o_audir._audir_sound_queue.map, _node.sound_id)){ show_debug_message("BURN BABy BurN"); return -1 }
	if (audio_is_playing(_node.sound_id)){
			audio_stop_sound(_node.sound_id);
	}
	var _prev	= __audir_get_queue_node(_node.previous);
	var _queue	= o_audir._audir_sound_queue;
	var _next	= __audir_get_queue_node(_node.next);
	var _val	= ((_prev != noone) + (2*(_next != noone)));
	
	o_audir._audir_current_noise_level -= _node.noise;
	o_audir._audir_sound_queue.len -= 1;
	
	switch(_val){
		case 0: // prev: noone, next: noone
			_queue.first	= noone;
			_queue.last		= noone;
			break
			
		case 1: // prev: NODE, next: noone
			_prev.next = noone;
			_queue.last = _prev.sound_id;
			break
			
		case 2: // prev: noone, next: NODE
			_next.previous = noone;
			_queue.first = _next.sound_id;
			break
			
		case 3: // prev: NODE, next: NODE
			_prev.next		= _next.sound_id;
			_next.previous	= _prev.sound_id;
			break
			
		default:
			break
	}
	ds_map_delete(_queue.map, _node.sound_id);
}


#endregion
//-------------------------------------
#region Info Macros
#macro AUDIR_VERSION	"0.2"
#macro AUDIR_DATE		"2022-07-31"
#endregion

show_debug_message("[ AuDir ] You are currently using AuDir Version:  " + string(AUDIR_VERSION) + "  ("+ string(AUDIR_DATE) + ")")