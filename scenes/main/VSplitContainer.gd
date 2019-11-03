extends SplitContainer

export var id:String

func hideControl():
	dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED

func showControl():
	dragger_visibility = SplitContainer.DRAGGER_VISIBLE