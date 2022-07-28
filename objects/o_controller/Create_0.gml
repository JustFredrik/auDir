
audir_init();
audir_instance_init();
audir_create_sfx("confirm", 
	[snd_confirm]);
	
map = ds_map_create();

audio_group_load(audiogroup1);
delta = current_time;