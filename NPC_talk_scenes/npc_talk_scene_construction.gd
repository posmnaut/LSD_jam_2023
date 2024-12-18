extends DialogicPortrait

func _update_portrait(passed_character:DialogicCharacter, passed_portrait:String) -> void:
	if passed_portrait == "":
		passed_portrait = passed_character['default_portrait']
	$AnimationPlayer.play("color_swap")
	if $Sprite.sprite_frames.has_animation(passed_portrait):
		$Sprite.play(passed_portrait)
		
func _on_sprite_animation_finished():
	$Sprite.frame = randi()%$Sprite.sprite_frames.get_frame_count($Sprite.animation)
	$Sprite.play()
		
func _get_covered_rect() -> Rect2:
	return Rect2($Sprite.position, $Sprite.sprite_frames.get_frame_texture($Sprite.animation, 0).get_size()*$Sprite.scale)
