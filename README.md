Let's say, you have an object that you want to decorate, thus
adding new attributes and methods to it. Here is how:

```ruby
require 'decoor'
s = ' Jeff Lebowski '
d = decoor(s, br: ' ') do
  def parts
    @origin.strip.split(@br)
  end
end
assert(d.parts == ['Jeff', 'Lebowski'])
```

You may also turn an existing class into a decorator:

```ruby
require 'decoor'
class MyString
  def initialize(s, br)
    @s = s
    @br = br
  end
  decoor(:s)
  def parts
    @origin.strip.split(@br)
  end
end
d = MyString.new('Jeff Lebowski')
assert(d.parts == ['Jeff', 'Lebowski'])
```

That's it.
