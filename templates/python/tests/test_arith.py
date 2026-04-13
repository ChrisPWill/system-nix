from __future__ import annotations

import unittest

from arith import add


class TestAdd(unittest.TestCase):
    """Behaviour of ``add``."""

    def test_adds_positive_integers(self) -> None:
        self.assertEqual(add(2, 3), 5)

    def test_adds_negative_and_positive(self) -> None:
        self.assertEqual(add(-1, 1), 0)

    def test_adds_floats(self) -> None:
        self.assertAlmostEqual(add(0.1, 0.2), 0.3, places=7)

    def test_add_examples(self) -> None:
        cases: tuple[tuple[int | float, int | float, int | float], ...] = (
            (0, 0, 0),
            (1, 2, 3),
            (-5, 5, 0),
        )
        for left, right, expected in cases:
            with self.subTest(left=left, right=right):
                self.assertEqual(add(left, right), expected)


if __name__ == "__main__":
    unittest.main()

