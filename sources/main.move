module movectf::maze {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;
    use std::vector;
    use movectf::counter::{Self, Counter};


    struct Maze has key, store{
        id: UID,
        map: vector<vector<u8>>
    }

    struct User has key, store {
        id: UID,
        x: u64,
        y: u64
    }

    struct Flag has copy, drop {
        user: address,
        flag: bool
    }

    // Map
    // ..#########
    // ....#...#.#
    // ###.#.###.#
    // #.#...#...#
    // #.#.#.###.#
    // #...#.#...#
    // #.#.#.###.#
    // #.#.#...#.#
    // ###.#.#.#.#
    // #...#.#....
    // ##########.

    // Map in vector, 0 for '.' and 1 for '#' 
    //[
    // 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    // 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1,
    // 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1,
    // 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1,
    // 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1,
    // 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1,
    // 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1,
    // 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1,
    // 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1,
    // 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0,
    // 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0
    // ]

    const Map: vector<u8> = vector[0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0];
    
    const EOUT_OF_RANGE: u64 = 1;
    fun init(ctx: &mut TxContext) {
        counter::create_counter(ctx);

        let i = 0;
        let line = vector::empty<u8>();
        let maze = vector::empty<vector<u8>>();
        while(i < vector::length(&Map)) {
            vector::push_back(&mut line, *vector::borrow(&Map, i));
            if ((i + 1) % 11 == 0) {
                vector::push_back(&mut maze, line);
                line = vector::empty<u8>();
            };
            i = i + 1;
        };

        transfer::share_object(Maze {
            id: object::new(ctx),
            map: maze
        });

        transfer::share_object(User {
            id: object::new(ctx),
            x: 0,
            y: 0
        });
    }

    public fun up(maze: &mut Maze, user: &mut User, step: u64) {
        user.x = user.x - step;
        let line = vector::borrow<vector<u8>>(&maze.map, user.x);
        assert!(*vector::borrow(line, user.y) != 1, EOUT_OF_RANGE);

    }

    public fun down(maze: &mut Maze, user: &mut User, step: u64) {
        user.x = user.x + step;
        let line = vector::borrow<vector<u8>>(&maze.map, user.x);
        assert!(*vector::borrow(line, user.y) != 1, EOUT_OF_RANGE);

    }

    public fun right(maze: &mut Maze, user: &mut User, step: u64) {
        user.y = user.y + step;
        let line = vector::borrow<vector<u8>>(&maze.map, user.x);
        assert!(*vector::borrow(line, user.y) != 1, EOUT_OF_RANGE);

    }

    public fun left(maze: &mut Maze, user: &mut User, step: u64) {
        user.y = user.y - step;
        let line = vector::borrow<vector<u8>>(&maze.map, user.x);
        assert!(*vector::borrow(line, user.y) != 1, EOUT_OF_RANGE);
    }

    public entry fun get_flag(user_counter: &mut Counter, user: &User, ctx: &mut TxContext) {
        counter::increment(user_counter);
        counter::is_within_limit(user_counter);

        assert!(user.x == 10 && user.y == 10, 0);
        event::emit(Flag {
            user: tx_context::sender(ctx),
            flag: true
        })
    }

    
}
