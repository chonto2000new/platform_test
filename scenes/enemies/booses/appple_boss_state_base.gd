class_name  AppleBossStateBase extends StateBase


var apple : AppleBoss:
	set(value):
		controlled_node = value
	get:
		return controlled_node
		
