class TestModule {
    @ProviderMethod
    fun provideThing(): Thing {
        return Thing()
    }

    class Impl : MissingImplementation
}
