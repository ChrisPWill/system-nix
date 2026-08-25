class Foo {
    fun deepNesting(x: Int): Int {
        if (x > 0) {
            if (x > 1) {
                if (x > 2) {
                    if (x > 3) {
                        return 4
                    }
                }
            }
        }
        return 0
    }
}
