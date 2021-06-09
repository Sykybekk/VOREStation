/obj/structure/panic_button
	name = "distress beacon trigger"
	desc = "Break glass, and push button. The ship's distress beacon will be deployed which, in theory, should bring help."
	icon = 'icons/obj/objects_vr.dmi'
	icon_state = "panicbutton"
	anchored = TRUE

	var/glass = TRUE
	var/launched = FALSE

// In case we're annihilated by a meteor
/obj/structure/panic_button/Destroy()
	if(!launched)
		launch()
	return ..()

/obj/structure/panic_button/update_icon()
	if(launched)
		icon_state = "[initial(icon_state)]_launched"
	else if(!glass)
		icon_state = "[initial(icon_state)]_open"
	else
		icon_state = "[initial(icon_state)]"

/obj/structure/panic_button/attack_hand(mob/living/user)
	if(!istype(user))
		return ..()
	
	if(user.incapacitated())
		return
	
	// Already launched
	if(launched)
		to_chat(user, "<span class='warning'>The button is already depressed; the beacon has been launched already.</span>")
	// Glass present
	else if(glass)
		if(user.a_intent == I_HURT)
			user.custom_emote(VISIBLE_MESSAGE, "smashes the glass on [src]!")
			glass = FALSE
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg')
			update_icon()
		else
			user.custom_emote(VISIBLE_MESSAGE, "pats [src] in a friendly manner.")
			to_chat(user, "<span class='warning'>If you're trying to break the glass, you'll have to hit it harder than that...</span>")
	// Must be !glass and !launched
	else
		user.custom_emote(VISIBLE_MESSAGE, "pushes the button on [src]!")
		launch(user)
		playsound(src, get_sfx("button"))
		update_icon()

/obj/structure/panic_button/proc/launch(mob/living/user)
	if(launched)
		return
	launched = TRUE
	//playsound(src, ) // TODO
	var/obj/effect/overmap/visitable/S = get_overmap_sector(z)
	if(!S)
		error("Distress button hit on z[z] but that's not an overmap sector...")
		return
	S.distress(user)
