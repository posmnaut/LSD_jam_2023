extends DialogicPortrait

func _update_portrait(passed_character:DialogicCharacter, passed_portrait:String) -> void:
	if passed_portrait == "":
		passed_portrait = passed_character['default_portrait']
	$AnimationPlayer.play("wave_swap")
	if $Control/Sprite.sprite_frames.has_animation(passed_portrait):
		$Control/Sprite.play(passed_portrait)
		
func _on_sprite_animation_finished():
	$Control/Sprite.frame = randi()%$Control/Sprite.sprite_frames.get_frame_count($Control/Sprite.animation)
	$Control/Sprite.play()
		
func _get_covered_rect() -> Rect2:
	return Rect2($Control/Sprite.position, $Control/Sprite.sprite_frames.get_frame_texture($Control/Sprite.animation, 0).get_size()*$Control/Sprite.scale)
