// Needed packages
const util = require('util');
const argv = require('yargs').argv;
const exec = util.promisify( require( 'child_process' ).exec );
const ngrok = require( 'ngrok' );
const { addExitHandler, getExitErrors } = require('shutdown-async');
addExitHandler( handleExit );

// Setup directories
const currentDir = process.cwd();

var siteData = {};

// ------------------------------------

(async function() {
  // Check rollback argument
  if ( argv.rollback || argv.r ) {
    await startRollbackProcess();
    return;
  } 
  
  siteData = await getCurrentInfo();
  main()
})();

// ------------------------------------

async function nginxPatching() {
  try {
    var path = await execCommand( 'grep -Rl "server_name .*' + getHostFromUrl( siteData.url ) + '.*;" /etc/nginx/custom-sites/' );
    var res = await execCommand( 'sudo sed -i -E "s#(server_name.*);#\\1 ' + getHostFromUrl( siteData.ngrok.url ) + ';#" "' + path + '"' );
    var res2 = await execCommand( 'sudo service nginx restart' );
  } catch( e ) {
    console.error(e);
  }
}

async function nginxUnPatching() {
  try {
    var path = await execCommand( 'grep -Rl "server_name .*' + getHostFromUrl( siteData.url ) + '.*;" /etc/nginx/custom-sites/' );
    var res = await execCommand( 'sudo sed -i -E "s#(server_name.*) ' + getHostFromUrl( siteData.ngrok.url ) + ';#\\1;#" "' + path + '"' );
    var res2 = await execCommand( 'sudo service nginx restart' );
  } catch( e ) {
    console.error(e);
  }
}

function getHostFromUrl(url) {
  return url.split('//')[1].split('/')[0];
}

async function getCurrentInfo() {
  var currentUrl = await getCurrentUrl();
  var currentHost = getHostFromUrl( currentUrl );

  return {
    url: currentUrl,
    host: currentHost,
    port: currentUrl.indexOf('https') >= 0 ? 443 : 80,
    ngrok: {
      subdomain: ( argv.subdomain ) ? argv.subdomain : false
    }
  }
}

function main() {
	ngrokConnect().then( startReplacementProcess );
}

async function startRollbackProcess() {
	console.log( 'Rockback process...' );
	return await rollbackUrls();
}

// ------------------------------------

function getCurrentUrl() {
	console.log( 'Getting current Url...' );
	return execCommand( 'wp option get home' );
}

async function replaceUrls( from, to ) {
  console.log( 'Replacing Urls from: ' + from, 'to: ' + to );
  await execCommand( `wp search-replace --precise --all-tables ${ from } ${ to }` );
  //console.log(getHostFromUrl(from));
}

async function rollbackUrls( currentUrl ) {
  var replaceFrom = siteData.ngrok.url.replace(/https?:/i, '');
  var replaceTo = siteData.url.replace(/https?:/i, '');
  await nginxUnPatching();
	return replaceUrls( replaceFrom, replaceTo ).then( res => {
		savePermalinks();
	} );
}

function savePermalinks() {
	console.log( 'Saving permalinks...' );
	return execCommand( 'wp rewrite flush' );
}

function startReplacementProcess( siteData ) {
  var replaceFrom = siteData.url.replace(/https?:/i, '')
  var replaceTo = siteData.ngrok.url.replace(/https?:/i, '')
  replaceUrls( replaceFrom, replaceTo ).then( res => {
    nginxPatching().then(savePermalinks).then( res => {
      console.log( '--- ' );
      console.log( 'ngrok running:', siteData.ngrok.url );
      console.log( 'Local Inspector:', siteData.ngrok.monitor );
    } );
  } )
}

// ------------------------------------

async function execCommand( command ) {
	const { stdout, stderr } = await exec( command );

	if ( stderr ) {
		console.error( stderr );
	}

	return stdout.replace(/\r?\n/g, '');
}

async function ngrokConnect() {
  var url;
  try {
    url = await ngrok.connect( {
      proto: 'http',
      addr: siteData.port,
      // host_header: siteData.host,
      bind_tls: siteData.port === 80 ? false : true,
      subdomain: siteData.ngrok.subdomain ? siteData.ngrok.subdomain : undefined,
    } );
  } catch( e ) {
    if( e.msg ) {
      console.error('ERROR: ' + e.msg);
    } else {
      console.error('Unknown error');
      console.error(e);
    }
    if( e.details && e.details.err ) {
      console.error(e.details.err);
    }
    process.exit();
  }

  const monitor = await ngrok.connect( {
		proto: 'http',
		addr: 4040,
    inspect: false,
    bind_tls: false,
  } );
  
  
  siteData.ngrok.url = url;
  siteData.ngrok.monitor = monitor;
  siteData.ngrok.subdomain = url.split('//')[1].split('.')[0];

	return siteData;
}

async function ngrokKill() {
	console.log( 'Killing ngrok...' );
	return await ngrok.kill();
}

// ------------------------------------

function handleExit() {

	console.log( '--- ' );

	return new Promise( ( resolve, reject ) => {
		ngrokKill().then(startRollbackProcess).then( res => {
			return resolve;
		} );
	} );
}
