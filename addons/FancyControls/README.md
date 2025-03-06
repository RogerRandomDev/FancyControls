
# FACS (Fancy Animated Controls System)

Addon For Godot 4.X that gives you a GUI to work with to create custom Control node animations based in a custom node container and item system. it is made to be easy to learn with a lot of capabilities for how it can be used.


## Features

- GUI interface for creating Animations
- GUI interface for creating/updating groups of animations to compile together
- High quantity of custom Container nodes
- Easy to learn code-based control of the plugin features


## Usage/Examples

The project contains an example folder with a simple example of the usage cases for it.
More complex usages include chaining multiple animations together to create multiple path animations, or, since the code itself is called as a function, can be directly called upon items to animate them.
## Documentation

### Animation System
This is the primary reason you are here, so I'll have it explained first.
The Animations are compiled, if done in the gui, down to functions that call the **`chain_action`** function on the item they are currently iterating over, and the function itself is called from the container holding the item using the function name as reference.
These functions contain the following data:
- item_node item being iterated
- current_item item node index
- total_items total number of items in container
- container_data data of the container itself
---
#### Creating an animation script yourself
If you wish to, you can create a function yourself and tell the group system to use it by giving it the file and telling it the method name to grab and use.
If you intend to also create a group file yourself, they have to be **`RefCounted`** script files as that is what it uses to store the script and run them.



## Contributing

Contributions are always welcome!

See `contributing.md` for ways to get started.

Please adhere to this project's `code of conduct`.


## License

[MIT](https://choosealicense.com/licenses/mit/)

