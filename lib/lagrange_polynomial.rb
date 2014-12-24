# https://en.wikipedia.org/wiki/Lagrange_polynomial#Barycentric_interpolation
class LagrangePolynomial

  # @param [Array] data [[x0, y0], [x1, y1], ...]
  def self.build(data)
    k = data.size - 1
    l = data.map { |point|
      Polynomial[-point[0], 1]
    }.reduce(:*)
    w = -> (j) {
      Rational 1, (0..k).inject(1) { |a, i|
        if i == j
          a
        else
          a * (data[j][0] - data[i][0])
        end
      }
    }
    (0..k).map { |j|
      (l * w.(j) * data[j][1]) / Polynomial[-data[j][0], 1]
    }.reduce(:+)
  end
end
