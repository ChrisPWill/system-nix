data class Config(val a: Int, val b: Int, val c: Int, val d: Int, val e: Int, val f: Int, val g: Int, val h: Int, val i: Int, val j: Int)

class Service(val a: Int, val b: Int, val c: Int, val d: Int, val e: Int, val f: Int, val g: Int, val h: Int, val i: Int)

class SmallService(val a: Int, val b: Int, val c: Int, val d: Int, val e: Int, val f: Int)

class Foo {
    fun manyParams(a: Int, b: Int, c: Int, d: Int, e: Int, f: Int): Int {
        return a
    }
}
