class Foo {
    fun noDefault(x: Int): String {
        return when (x) {
            0 -> "zero"
            1 -> "one"
        }
    }

    fun hasDefault(x: Int): String {
        return when (x) {
            0 -> "zero"
            else -> "other"
        }
    }
}
