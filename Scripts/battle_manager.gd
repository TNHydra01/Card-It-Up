extends Node


# -- Constants --
const CARD_SMALLER_SCALE = 0.6
const CARD_MOVE_SPEED = 0.2


# -- Variables --
var batte_timer
var empty_monster_card_slots = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	batte_timer = $"../BattleTimer"
	batte_timer.one_shot = true
	batte_timer.wait_time = 1.0
	
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot2")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot3")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot4")
	empty_monster_card_slots.append($"../CardSlots/EnemyCardSlot5")


func _on_end_turn_button_pressed() -> void:
	opponent_turn()


func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	# If can draw a card, draw then wait 1 second
	if $"../OpponentDeck".opponent_deck.size() != 0:
		$"../OpponentDeck".draw_card()
		# Wait 1 second
	batte_timer.start()
	await batte_timer.timeout
	
	# Check if any free monster card slots, and if no, end turn
	if empty_monster_card_slots.size() == 0:
		end_opponent_turn()
		return
	
	# Try play card and wait 1 sec if played 
	await try_play_card_with_highest_attack()

	end_opponent_turn()


func try_play_card_with_highest_attack():
# Get random empty slot to play the card in
	var opponent_hand = $"../OpponentHand".opponent_hand
	if opponent_hand.size() == 0:
		end_opponent_turn()
		return
	
	
	var random_empty_monster_card_slot = empty_monster_card_slots[randi_range(0, empty_monster_card_slots.size() - 1)]
	empty_monster_card_slots.erase(random_empty_monster_card_slot)
	
	# Play a card in the hand with the highest attack
	var card_with_highest_atk = opponent_hand[0]
	for card in opponent_hand:
		if card.attack >  card_with_highest_atk.attack:
			card_with_highest_atk = card
	
	# Animate card to position
	var tween = get_tree().create_tween()
	tween.tween_property(card_with_highest_atk, "position", random_empty_monster_card_slot.position, CARD_MOVE_SPEED)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(card_with_highest_atk, "scale", Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE), CARD_MOVE_SPEED)
	card_with_highest_atk.get_node("AnimationPlayer").play("card_flip")
	
	# Remove the card from opponents hand
	$"../OpponentHand".remove_card_from_hand(card_with_highest_atk)
	
	# Wait 1 second
	batte_timer.start()
	await batte_timer.timeout



func end_opponent_turn():
	$"../Deck".reset_draw()
	$"../CardManager".reset_played_monster()
	$"../EndTurnButton".visible = true
	$"../EndTurnButton".disabled = false
