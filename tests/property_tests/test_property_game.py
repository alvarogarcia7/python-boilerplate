"""Property-based tests using Hypothesis (https://hypothesis.readthedocs.io).

These tests complement the example-based tests in ``tests/test_game.py`` by
asserting *invariants* that should hold for a wide range of generated inputs.
Hypothesis searches the input space and, on failure, shrinks counter-examples
down to a minimal reproducer.
"""

from __future__ import annotations

import unittest

from hypothesis import given, strategies as st

from app.main import Game, Player, PlayerRepository, UIRepresentation

# A name is a single, non-empty token with no whitespace, because ``Game.run``
# splits the command on spaces and keeps only the last token as the player name.
names = st.text(
    alphabet="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
    min_size=1,
    max_size=10,
)


class TestPlayerProperties(unittest.TestCase):
    @given(start=st.integers(), spaces=st.integers())
    def test_move_advances_by_exactly_the_given_spaces(
        self, start: int, spaces: int
    ) -> None:
        player = Player("P", start)

        player.move(spaces)

        self.assertEqual(player.position, start + spaces)

    @given(start=st.integers(), first=st.integers(), second=st.integers())
    def test_move_is_additive(self, start: int, first: int, second: int) -> None:
        # Moving by ``first`` then ``second`` lands on the same square as moving
        # by their sum in a single step.
        stepwise = Player("P", start)
        stepwise.move(first)
        stepwise.move(second)

        single = Player("P", start)
        single.move(first + second)

        self.assertEqual(stepwise.position, single.position)


class TestUIRepresentationProperties(unittest.TestCase):
    def setUp(self) -> None:
        self.ui = UIRepresentation()

    @given(position=st.integers())
    def test_position_rendering(self, position: int) -> None:
        expected = "Start" if position == 0 else str(position)

        self.assertEqual(self.ui.position(position), expected)

    @given(values=st.lists(st.integers()))
    def test_get_die_values_round_trips(self, values: list[int]) -> None:
        rendered = [str(value) for value in values]

        self.assertEqual(self.ui.get_die_values(rendered), values)

    @given(values=st.lists(st.integers(), min_size=1))
    def test_get_die_values_ignores_surrounding_whitespace(
        self, values: list[int]
    ) -> None:
        rendered = [f"  {value}  " for value in values]

        self.assertEqual(self.ui.get_die_values(rendered), values)

    @given(value=st.integers(min_value=0))
    def test_get_die_values_strips_commas(self, value: int) -> None:
        # The parser removes every comma, so a comma-grouped number such as
        # "1,234" is read back as 1234.
        digits = str(value)
        with_commas = ",".join(digits[i : i + 3] for i in range(0, len(digits), 3))

        self.assertEqual(self.ui.get_die_values([with_commas]), [value])


class TestGameAddProperties(unittest.TestCase):
    @given(player_names=st.lists(names, unique=True, min_size=1, max_size=6))
    def test_adding_distinct_players_lists_them_in_order(
        self, player_names: list[str]
    ) -> None:
        game = Game(PlayerRepository())

        response = ""
        for name in player_names:
            response = game.run(f"add player {name}")

        self.assertEqual(response, f"players: {', '.join(player_names)}")

    @given(name=names)
    def test_adding_the_same_player_twice_is_rejected(self, name: str) -> None:
        game = Game(PlayerRepository())
        game.run(f"add player {name}")

        response = game.run(f"add player {name}")

        self.assertEqual(response, f"{name}: already existing player")


class TestGameMoveProperties(unittest.TestCase):
    @given(start=st.integers(min_value=0, max_value=62))
    def test_landing_exactly_on_63_wins(self, start: int) -> None:
        game = Game(PlayerRepository())
        player = Player("winner", start)
        roll = 63 - start

        message = game.compose_moving_message(player, [roll])

        self.assertIn("wins!!", message)
        self.assertEqual(player.position, 63)

    @given(start=st.integers(min_value=0, max_value=62), overshoot=st.integers(min_value=1, max_value=62))
    def test_overshooting_63_bounces_back(self, start: int, overshoot: int) -> None:
        game = Game(PlayerRepository())
        player = Player("bouncer", start)
        roll = (63 - start) + overshoot  # guarantees landing past 63

        message = game.compose_moving_message(player, [roll])

        # Bouncing reflects the overshoot back from square 63.
        self.assertIn("bounces", message)
        self.assertEqual(player.position, 63 - overshoot)
        self.assertLess(player.position, 63)

    @given(start=st.integers(min_value=0, max_value=62), data=st.data())
    def test_short_move_neither_wins_nor_bounces(
        self, start: int, data: st.DataObject
    ) -> None:
        roll = data.draw(st.integers(min_value=0, max_value=62 - start))
        game = Game(PlayerRepository())
        player = Player("walker", start)

        message = game.compose_moving_message(player, [roll])

        self.assertNotIn("wins!!", message)
        self.assertNotIn("bounces", message)
        self.assertEqual(player.position, start + roll)


if __name__ == "__main__":
    unittest.main()
