# Some nasty Array-Monkeypatches
class Array
  def rand
    self[Kernel.rand(length)]
  end unless Array.methods.include?("rand")
  
  # works like rand, but returns n random elements from self
  # if n >= self.lenth, self is returned
  def randn(n)
    return self if n >= length
    ret = []
    while (ret.length < n) do
      dummy = rand
      ret << dummy unless ret.member?(dummy)
    end
    ret
  end unless Array.methods.include?("randn")
end