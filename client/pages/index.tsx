import { useState, useEffect, useRef} from 'react';
import styles from '../styles/Home.module.css';
import RoyaltiesABI from '../abi/RoyaltiesDistribution.json';
import RoyaltiesBytecode from '../bytecode/Royalties.json';


declare global {
  interface Window {
    tronWeb: any;
  }
}

export default function Home() {
  const [tronWebFlag, setTronWebFlag] = useState<any>(null);  //<--- Puede que el issue este en esta variable confundida con instancia tronweb
  const [contract, setContract] = useState<any>(null);
  const [account, setAccount] = useState<string | null>(null);
  const [isContractDeployed, setIsContractDeployed] = useState<boolean>(false);
  const [isDeploying, setIsDeploying] = useState<boolean>(false);
  const [contractAddress, setContractAddress] = useState<string | null>('');
  const dashboardRef = useRef<HTMLDivElement>(null);
  const aboutUsRef = useRef<HTMLDivElement>(null);
  const [activeSection, setActiveSection] = useState('home');
  useEffect(() => {
    const initTronWeb = async () => {
      if (window.tronWeb && window.tronWeb.ready) {
        setAccount(window.tronWeb.defaultAddress.base58);
        setTronWebFlag(true);
        const acc = await window.tronWeb.trx.getAccount();
        console.log(acc.address);
        //setAccount(acc.address);
      }
    };

    initTronWeb();
    const handleScroll = () => {
      const dashboardTop = dashboardRef.current?.offsetTop || 0;
      const aboutUsTop = aboutUsRef.current?.offsetTop || 0;
      const scrollPosition = window.scrollY + 200; // Adjust based on your navbar height

      if (scrollPosition >= aboutUsTop) {
        setActiveSection('about-us');
      } else if (scrollPosition >= dashboardTop) {
        setActiveSection('dashboard');
      } else {
        setActiveSection('home');
      }
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const connectWallet = async () => {
    if (window.tronWeb) {
      try {
        await window.tronWeb.request({ method: 'tron_requestAccounts' });
        const acc = await window.tronWeb.trx.getAccount();
        setAccount(window.tronWeb.defaultAddress.base58);
      } catch (error) {
        console.error('Failed to connect wallet:', error);
      }
    } else {
      alert('Please install TronLink extension');
    }
  };

  const deployContract = async () => {
    if (!tronWebFlag) {
      alert('Please connect your wallet first');
      return;
    }

    setIsDeploying(true);
    console.log(RoyaltiesABI.abi);
    console.log(RoyaltiesBytecode.object);

    try {
      let transaction = await window.tronWeb.transactionBuilder.createSmartContract({
        abi: RoyaltiesABI.abi,
        bytecode: RoyaltiesBytecode.object,
        feeLimit: 400000000,
        callValue: 0,
        userFeePercentage: 50,
        originEnergyLimit: 10000000,
        parameters: ['TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf'],

      }, window.tronWeb.defaultAddress.hex);

      console.log(transaction.address);

      const signedTransaction = await window.tronWeb.trx.sign(transaction);
      const contract_instance = await window.tronWeb.trx.sendRawTransaction(signedTransaction);

      console.log('Contract deployed at:', contract_instance.transaction.contract_address);
      setContractAddress(contract_instance.transaction.contract_address);
      setIsContractDeployed(true);

      // const instance = await window.tronWeb.contract(RoyaltiesABI, contract_instance.address);
      setContract(contract_instance);
    } catch (error) {
      console.error('Failed to deploy contract:', error);
      alert('Failed to deploy contract. Please check the console for details.');
    } finally {
      setIsDeploying(false);
    }
  };
  const scrollToSection = (ref: React.RefObject<HTMLDivElement>) => {
    if (ref.current) {
      ref.current.scrollIntoView({ behavior: 'smooth' });
    }
  };



  const addPayee = async () => {
    if (!tronWebFlag || !contract) {
      alert('Please connect your wallet and deploy the contract first');
      return;
    }

    const address = prompt('Enter payee address:');
    const share = prompt('Enter payee share:');

    if (!address || !share) {
      alert('Invalid input');
      return;
    }

    try {

      let contract = await window.tronWeb.contract(RoyaltiesABI.abi, contractAddress);
      let txID = await contract.addPayee(address, share).send();
      let result = await window.tronWeb.trx.getTransaction(txID);
      console.log("Execution result:", result);
      //console.log('Payee added:', result);
      alert('Payee added successfully');
    } catch (error) {
      console.error('Failed to add payee:', error);
      alert('Failed to add payee. Please check the console for details.');
    }
  };

  const removePayee = async () => {
    if (!tronWebFlag || !contract) {
      alert('Please connect your wallet and deploy the contract first');
      return;
    }

    const address = prompt('Enter payee address to remove:');

    if (!address) {
      alert('Invalid input');
      return;
    }

    try {

      let contract = await window.tronWeb.contract(RoyaltiesABI.abi, contractAddress);
      let txID = await contract.removePayee(address).send();
      let result = await window.tronWeb.trx.getTransaction(txID);
      console.log('Payee removed:', result);
      alert('Payee removed successfully');
    } catch (error) {
      console.error('Failed to remove payee:', error);
      alert('Failed to remove payee. Please check the console for details.');
    }
  };

  const updateTokenContract = async () => {
    if (!tronWebFlag || !contract) {
      alert('Please connect your wallet and deploy the contract first');
      return;
    }

    const newTokenAddress = prompt('Enter new token contract address:');

    if (!newTokenAddress) {
      alert('Invalid input');
      return;
    }

    try {

      let contract = await window.tronWeb.contract(RoyaltiesABI.abi, contractAddress);
      let txID = await contract.updateTokenContract(newTokenAddress).send();
      let result = await window.tronWeb.trx.getTransaction(txID);
      console.log('Token contract updated:', result);
      alert('Token contract updated successfully');
    } catch (error) {
      console.error('Failed to update token contract:', error);
      alert('Failed to update token contract. Please check the console for details.');
    }
  };

  const distributeRoyalties = async () => {
    if (!tronWebFlag || !contract) {
      alert('Please connect your wallet and deploy the contract first');
      return;
    }

    try {
      /*const result = await executeTransaction(
        'distributeRoyalties()',
        [],
        { feeLimit: 1000000000 }
      );*/
      let contract = await window.tronWeb.contract(RoyaltiesABI.abi, contractAddress);
      let txID = await contract.distributeRoyalties().send();
      let result = await window.tronWeb.trx.getTransaction(txID);
      console.log('Royalties distributed:', result);
      alert('Royalties distributed successfully');
    } catch (error) {
      console.error('Failed to distribute royalties:', error);
      alert('Failed to distribute royalties. Please check the console for details.');
    }
  };

  return (
    <div className={styles.container}>
      {/* Header with navigation and logo */}
      <header className={styles.header}>
        <div className={styles.logoNav}>
          <img src="/stakelogo.png" alt="Stakecess Logo" className={styles.logo} />
        </div>

        {/* Navigation Links */}
        <nav className={styles.nav}>
          <a
            href="#"
            className={`${styles.navLink} ${activeSection === 'home' ? styles.activeLink : ''}`}
            onClick={() => scrollToSection({ current: null })}>
            Home
          </a>
          <a
            href="#"
            className={`${styles.navLink} ${activeSection === 'dashboard' ? styles.activeLink : ''}`}
            onClick={() => scrollToSection(dashboardRef)}>
            Dashboard
          </a>
          <a
            href="#"
            className={`${styles.navLink} ${activeSection === 'about-us' ? styles.activeLink : ''}`}
            onClick={() => scrollToSection(aboutUsRef)}>
            About Us
          </a>
        </nav>

        {/* Connect Wallet Button */}
        <div className={styles.connectButtonWrapper}>
          <button className={styles.connectButton} onClick={connectWallet}>
            {account ? `Connected: ${account.slice(0, 6)}...${account.slice(-4)}` : 'Connect Wallet'}
          </button>
        </div>
      </header>

      {/* Main Hero Section */}
      <main className={styles.main}>
        <h1 className={styles.heroTitle}>Stakecess - Learn2Earn</h1>
        <p className={styles.heroSubtitle}>
          Bet on Progress, $take your Success
        </p>
        {!isContractDeployed ? (
          <div className={styles.deployButtonWrapper}>
            <button
              className={styles.deployButton}
              onClick={() => {
                deployContract();
                scrollToSection(dashboardRef); // Scroll to dashboard after creating a study group
              }}
              disabled={isDeploying || !account}>
              {isDeploying ? 'Deploying...' : 'Create Study Group'}
            </button>
          </div>
        ) : null}
      </main>

      {/* Dashboard Section */}
      <div ref={dashboardRef} className={styles.dashboard}>
        <h2 className={styles.sectionTitle}>Dashboard</h2>
        {isContractDeployed ? (
          <div className={styles.buttonGrid}>
            <button className={styles.button} onClick={addPayee}>Add Payee</button>
            <button className={styles.button} onClick={removePayee}>Remove Payee</button>
            <button className={styles.button} onClick={updateTokenContract}>Update Token Contract</button>
            <button className={styles.button} onClick={distributeRoyalties}>Distribute Royalties</button>
          </div>
        ) : null}
      </div>

      {/* About Us Section */}
      <div ref={aboutUsRef} className={styles.aboutUs}>
        <h2 className={styles.sectionTitle}>About Us</h2>
        <p>
          Stakecess is a platform that allows students to stake crypto while working to improve their grades.
          The more they study, the better their grades, the more they earn.
        </p>
      </div>
    </div>
  );
}