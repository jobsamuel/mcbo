const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('MCBO', function () {
  it('Should accept tips from anyone and reset balance after claims', async function () {
    const signers = await ethers.getSigners()
    const Mcbo = await ethers.getContractFactory('MCBO')
    const mcbo = await Mcbo.deploy()
    await mcbo.deployed()

    expect(await mcbo.getBalance()).to.equal(0)

    const id = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('+584140123456'))

    await mcbo
      .connect(signers[0])
      .sendTip(id, { value: ethers.utils.parseEther('1') })
    await mcbo
      .connect(signers[1])
      .sendTip(id, { value: ethers.utils.parseEther('1') })

    expect(await mcbo.getBalance()).to.equal(ethers.utils.parseEther('2'))

    await mcbo.connect(signers[2]).claimTip(id)

    expect(await mcbo.balances(id)).to.equal(0)

    expect(await mcbo.getBalance()).to.equal(0)
  })
})
