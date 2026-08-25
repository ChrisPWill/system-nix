class Foo {
    fun classify(n: Int): String {
        if (n > 10) {
            return "big"
        } else if (n > 0) {
            return "small"
        } else {
            return "non-positive"
        }
    }
}
