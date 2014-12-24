require 'spec_helper'

describe LagrangePolynomial do

  it 'can be built from data' do
    expect(
      LagrangePolynomial.build([[-1.5, -14.1014], [-0.75, -0.931596], [0, 0], [0.75, 0.931596], [1.5, 14.1014]])
    ).to eq Polynomial[0, -1.4774737777777793, 0, 4.834847604938272]
    expect(
      LagrangePolynomial.build([[1, 1], [2, 4], [3, 9]])
    ).to eq Polynomial[0, 0, 1]
    expect(
      LagrangePolynomial.build([[1, 1], [2, 8], [3, 27]])
    ).to eq Polynomial[6, -11, 6]
  end
end
