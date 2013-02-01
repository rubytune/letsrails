class Foo
  def self.make_foo
    define_method(:foo) { "foo" }
  end
end

Foo.make_foo
foo = Foo.new
puts foo.foo