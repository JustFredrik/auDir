/// @description initialize variables and declare methods

most_recent = ""
function draw_data(){
	draw_text(40, 40, audir_sfx_is_playing("confirm") );
	draw_text(40, 60, current_time - _audir_sfx_maintainer[? "confirm"].last_time);
	draw_text(40,80, _audir_sfx_maintainer[? "confirm"].min_delta);
	draw_text(40,100, string(_audir_current_noise_level));
	draw_text(40,120, string(audir_get_active_sfx_count()));
}

#region Variables

_audir_master_gain	= AUDIR_DEFAULT_MASTER_GAIN;
_audir_music_gain	= AUDIR_DEFAULT_MUSIC_GAIN;
_audir_sfx_gain		= AUDIR_DEFAULT_SFX_GAIN;
_audir_ambiance		= AUDIR_DEFAULT_AMBIANCE_GAIN;
_audir_sfx_groups	= ds_map_create();
audir_create_sfx_group(AUDIR_DEFAULT_SFX_GROUP, AUDIR_DEFAULT_SFX_GAIN);

_audir_sound_queue	= {
	first	: noone,
	last	: noone,
	len		: 0,
	map		: ds_map_create()
};

_audir_emitter_maintainer	= ds_map_create();	// List used to track pairs of instances and their emitters
_audir_sfx_maintainer		= ds_map_create();	// Map of all developer defined sound effects

_audir_current_noise_level = 0;
#endregion

#region Methods

/// @func	_audir_clean_up_emitters()
/// @desc	Cleans up "dead" emitters incase instances has been incorrectly deleted.
function _audir_clean_up_emitters(){
	var _len = ds_list_size(emitter_maintainer);
	for(var _i = 0; _i<_len; _i++){
		if !(instance_exists(_audir_emitter_maintainer[|_i][0])){
			if audio_emitter_exists(_audir_emitter_maintainer[|_i][1]){
				audio_emitter_free(_audir_emitter_maintainer[|_i][1]);
			}
			ds_list_delete(_audir_emitter_maintainer, _i);
		}
	}
}

function _audir_clean_up_sfx(_sfx_name){
	// Play SFX should auto clean up SFXs but SFX's that haven't
	// Been played for a long time may just have dead stuff in memory
	var _sfx = o_audir._audir_sfx_maintainer[? _sfx_id];
	var _last_played_len = ds_list_size(_sfx.last_played_id);
	var return_val = 0, _i = 0;
	
	while (_i < _last_played_len){
		if (audio_is_playing(_sfx.last_played_id[| _last_played_len - _i])){
		_i += 1;	
		} else { // If sound isn't being played, then remove it from tracking
			ds_list_delete(_sfx.last_played_id,		_last_played_len - _i);	
			ds_list_delete(_sfx.last_played_name,	_last_played_len - _i);	
			_last_played_len -= 1;
		}
	}
}
#endregion
