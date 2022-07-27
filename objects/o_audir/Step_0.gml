/// @description Insert description here
// You can write your code in this editor

if (keyboard_check_pressed(vk_space)){
	last_played = ""
	audir_play_sfx("confirm", o_controller);
}


// Cull sounds when Noise is too High
var _node, _tmp_node;
while(_audir_current_noise_level > AUDIR_MAX_NOISE_LEVEL){
	_node = __audir_get_queue_node(_audir_sound_queue.last);
	__audir_remove_sfx_from_queue(_node);
}


// Cull Dead sounds from queue
_node	= __audir_get_queue_node(_audir_sound_queue.first);
var _i	= AUDIR_SFX_CULLING_RATE;

while((_i >> 0) && (_node != noone)){
	_tmp_node = __audir_get_queue_node(_node.next);
	if (_node == noone){
		break
	}
	if (!audio_is_playing(_node.sound_id)){
		__audir_remove_sfx_from_queue(_node);
	}
	_node = _tmp_node;
	_i -= 1;
}

