/// @description initialize variables and declare methods

most_recent = ""
function draw_data(){
	static sound_id = audio_play_sound_at(snd_confirm, x, y, x, 100, 100, 0, false, 1);	
	draw_text(40, 40, audio_is_playing(sound_id));
	draw_text(40, 60, audio_is_playing(snd_confirm));
	draw_text(40,80, string(sound_id));
	draw_text(40,100, string(most_recent));
}

#region Variables

_audir_master_gain = AUDIR_DEFAULT_MASTER_GAIN;
_audir_music_gain	= AUDIR_DEFAULT_MUSIC_GAIN;
_audir_sfx_gain		=	AUDIR_DEFAULT_SFX_GAIN;
_audir_ambiance	= AUDIR_DEFAULT_AMBIANCE_GAIN;

_audir_emitter_maintainer	= ds_map_create();	// List used to track pairs of instances and their emitters
_audir_sfx_maintainer			= ds_map_create();	// Map of all developer defined sound effects

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


function _audir_update_noise_level(){
		
}
#endregion
