const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('MCBO', function () {
  it('Should accept tips from anyone', async function () {
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
  })

  it('Should create user and accept tips using user ID', async function () {
    const signers = await ethers.getSigners()
    const Mcbo = await ethers.getContractFactory('MCBO')
    const mcbo = await Mcbo.deploy()
    await mcbo.deployed()

    const id = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('+584140123456'))

    await mcbo.connect(signers[0]).createUser(id, signers[2].address)

    await mcbo
      .connect(signers[0])
      .sendTipToUser(0, { value: ethers.utils.parseEther('1') })

    await mcbo
      .connect(signers[0])
      .sendTipToUser(0, { value: ethers.utils.parseEther('1') })

    expect(await mcbo.getBalance()).to.equal(ethers.utils.parseEther('2'))

    expect(await mcbo.balances(id)).to.equal(ethers.utils.parseEther('2'))

    await mcbo.connect(signers[0]).transferTipToUserWallet(0)

    expect(await mcbo.balances(id)).to.equal(0)

    expect(await mcbo.getBalance()).to.equal(0)

    expect(await signers[2].getBalance()).to.equal(
      ethers.utils.parseEther('10002')
    )
  })
})
