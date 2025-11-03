# Bug Report: TheZummoning Project

## CRITICAL BUGS

### 1. Loop Invariant Clearing Cards in forge.gd
- **File**: `scenes/forge.gd`
- **Lines**: 67-69
- **Issue**: `cards_played_here = []` is reset inside the for loop on every iteration
- **Impact**: Only the first card in `cards_played_here` will be processed; all subsequent iterations operate on an empty list
- **Code**:
  ```gdscript
  for card in cards_played_here:
      card.queue_free.call_deferred()
      cards_played_here = []  # BUG: Clears list every iteration
  ```
- **Fix**: Move `cards_played_here = []` outside the loop
- **Status**: [ ] TODO

### 2. Missing Group Registration for Cards in player_hand.gd
- **File**: `scenes/player_hand.gd`
- **Lines**: 22-25
- **Issue**: `_on_child_order_changed()` filters cards by the "cards" group, but cards are never added to this group. Cards are only added to "playable" group in `deck.gd` line 30.
- **Impact**: The `cards` array will always be empty, breaking card repositioning logic
- **Code**:
  ```gdscript
  cards=get_children().filter(func(c):
      return c.is_in_group("cards")  # No cards are ever added to this group!
  )
  ```
- **Fix**: Either add cards to "cards" group when creating them, or filter by "playable" group instead
- **Status**: [ ] TODO

---

## HIGH PRIORITY ISSUES

### 3. Unhandled Dictionary Key Access in creature.gd
- **File**: `scenes/creature.gd`
- **Lines**: 117, 146
- **Issue**: No null/missing key checking when accessing `creature_resources` dictionary
- **Impact**: Game will crash if a card references a creature that doesn't exist in the dictionary
- **Code**:
  ```gdscript
  description = creature_resources[resource_name]  # Can throw KeyError
  return Creature.creature_resources[lookup_name]  # Can throw KeyError
  ```
- **Fix**: Add has() check or use get() with default value before accessing
- **Status**: [ ] TODO

### 4. Potential Null Reference in card.gd
- **File**: `scenes/card.gd`
- **Lines**: 92-98
- **Issue**: `body_ref` is used without null check after checking `is_inside_dropable`
- **Impact**: Race condition where body exits between check and usage could cause null reference crash
- **Code**:
  ```gdscript
  if is_inside_dropable:
      tween.tween_property(self, "global_position", body_ref.global_position,0.2)
      body_ref.modulate = Color(Color.WHITE, 1)
      body_ref.card_dropped(self)
  ```
- **Fix**: Add null check on `body_ref` before using it
- **Status**: [ ] TODO

---

## MEDIUM PRIORITY ISSUES

### 5. Logic Error in main.gd - End Turn Button State
- **File**: `scenes/main.gd`
- **Lines**: 45-51
- **Issue**: Button is only enabled when cards played <= 2, but no else clause disables it when >= 2
- **Impact**: Button remains enabled even when player shouldn't be allowed to end turn
- **Code**:
  ```gdscript
  func configure_turn_ui():
      if cards_played_this_turn <= 2:
          $EndTurnControls/EndTurnButton.disabled=false
      if cards_played_this_turn > 1:  # No else to disable button
          for forge in player_forges:
              forge.close()
  ```
- **Fix**: Add else clause to disable button when cards_played_this_turn > 2
- **Status**: [ ] TODO

### 6. Unhandled Dictionary Key Access in forge.gd
- **File**: `scenes/forge.gd`
- **Lines**: 123-124
- **Issue**: `modifier["Name Modifier"]` accessed without existence check
- **Impact**: Will crash with KeyError if CSV data doesn't include "Name Modifier" field
- **Code**:
  ```gdscript
  if base and modifier:
      creature_name = modifier["Name Modifier"].replace("%", base.Creates)
  ```
- **Fix**: Check if "Name Modifier" key exists before accessing
- **Status**: [ ] TODO

### 7. Redundant Null Check in forge.gd
- **File**: `scenes/forge.gd`
- **Lines**: 70-75
- **Issue**: `creature_details` is checked twice (second check always true due to early return)
- **Impact**: Dead code path; minor but indicates logic review needed
- **Code**:
  ```gdscript
  if not creature_details:
      return
  if creature_details:  # Always true here
      var new_creature = creature_scene.instantiate()
  ```
- **Fix**: Remove redundant second check
- **Status**: [ ] TODO

---

## LOW PRIORITY ISSUES

### 8. Missing Null Safety Check in dragging.gd
- **File**: `autoload/dragging.gd`
- **Lines**: 8-10
- **Issue**: `information_label` and `timer` accessed without null checks
- **Impact**: Could crash if parent node structure doesn't match expected layout
- **Code**:
  ```gdscript
  information_label.text=text  # Could be nil on first call
  timer.start()
  ```
- **Fix**: Add null checks or lazy initialization
- **Status**: [ ] TODO

### 9. Incomplete Conditional in card.gd
- **File**: `scenes/card.gd`
- **Lines**: 85-87
- **Issue**: Empty line in the middle of conditional logic (likely formatting error)
- **Code**:
  ```gdscript
  if Input.is_action_pressed("click"):

      global_position = get_global_mouse_position()
  ```
- **Fix**: Clean up formatting
- **Status**: [ ] TODO

---

## Summary

- **Critical Issues**: 2
- **High Priority**: 2
- **Medium Priority**: 3
- **Low Priority**: 2
- **Total**: 9 bugs to fix

Most urgent: forge.gd line 69, player_hand.gd line 22-25, and creature.gd lines 117 & 146
