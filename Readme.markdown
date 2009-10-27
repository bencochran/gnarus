Gnarus
======

[Gnarus][gnarus] is an augmented reality application for the iPhone. It was designed at [Carleton College][carleton] as a [comps project][comps].

Building
--------

To build the application, simply clone this repository then pull in git submodules. This will look something like this:

    $ git clone git@github.com:bcochran/gnarus.git
    $ cd gnarus/
    $ git submodule init
    $ git submodule update

Then it's just a matter of opening the main project in Xcode, making sure your build settings are correct (simulator/device), and clicking "Build & Run"

[gnarus]:http://gnar.us
[carleton]:http://carleton.edu
[comps]:http://cs.carleton.edu/cs_comps/0910/augmentedreality/index.php