import firebase from "@firebase/app"
import "@firebase/firestore"
import "@firebase/storage"

const snapshotIniti = do|callback=do $1|
	this:firestore:app:__unsubscribe__.set this:path, this.onSnapshot
		observable: this
		next: do|snapshot|
			this:observable:firestore:app:__callback__() if this:observable:firestore:app:__response__.set this:observable:path, callback snapshot:docs or snapshot.data or null

const snapshotResponse = do |callback|
	unless this:firestore:app:__unsubscribe__.has this:path then snapshotIniti:apply this, callback
	this:firestore:app:__response__.get this:path

# --- DocumentReference ---

Object.defineProperty firebase:firestore:DocumentReference:prototype, 'response',
	value: do|callback| snapshotResponse:apply this, [ callback ]

Object.defineProperty firebase:firestore:DocumentReference:prototype, 'storage',
	value: do|uid| this:firestore:app:__storage__.ref().child this:path

Object.defineProperty firebase:firestore:DocumentReference:prototype, 'destroy',
	value: do
		if this:firestore:app:__unsubscribe__.has this:path then this:firestore:app:__unsubscribe__.get( this:path )()
		if this:firestore:app:__response__.has this:path then this:firestore:app:__response__.delete this:path

# --- CollectionReference ---

Object.defineProperty firebase:firestore:CollectionReference:prototype, 'response',
	value: do|callback| snapshotResponse:apply this, [ callback ]

Object.defineProperty firebase:firestore:CollectionReference:prototype, 'destroy',
	value: do
		if this:firestore:app:__unsubscribe__.has this:path then this:firestore:app:__unsubscribe__.get( this:path )()
		if this:firestore:app:__response__.has this:path then this:firestore:app:__response__.delete this:path

# --- Query ---

Object.defineProperty firebase:firestore:Query:prototype, 'response',
	value: do|callback|
		unless this:path then Object.defineProperty this, 'path', { value: JSON.stringify( this:_delegate:_query ) }
		snapshotResponse:apply this, [ callback ]

Object.defineProperty firebase:firestore:Query:prototype, 'destroy',
	value: do
		if this:firestore:app:__unsubscribe__.has this:path then this:firestore:app:__unsubscribe__.get( this:path )()
		if this:firestore:app:__response__.has this:path then this:firestore:app:__response__.delete this:path

Object.defineProperty firebase:firestore:Query:prototype, 'filters',
	value: do Map.new this:_delegate:_query:filters.map do|item| [ item ]


# --- Firestore:functions ---

Object.defineProperty firebase:firestore:Firestore:prototype, 'FieldValue',
	value: firebase:firestore:FieldValue

Object.defineProperty firebase:firestore:Firestore:prototype, 'FieldPath',
	value: firebase:firestore:FieldPath

Object.defineProperty firebase:firestore:Firestore:prototype, 'GeoPoint',
	value: firebase:firestore:GeoPoint

Object.defineProperty firebase:firestore:Firestore:prototype, 'Timestamp',
	value: firebase:firestore:Timestamp

Object.defineProperty firebase:firestore:Firestore:prototype, 'destroy',
	value: do for item in this:app:__unsubscribe__.keys
		this:app:__unsubscribe__.get( item )()
		this:app:__response__.delete( item )


export class Segment
	prop waiting

	def initialize
		collection = $1

export def destroy server
	if firebase:apps.filter( do |item| item:name == server ):length == 0 then Promise.new do|resolve, reject| resolve()
	else firebase.app( server ).delete


export default def initFirebase apikeyweb, callback, name
	let fb = firebase.initializeApp apikeyweb, name
	Object.defineProperty fb, '__callback__', { value: do callback ? callback() : $1 }
	Object.defineProperty fb, '__unsubscribe__', { value: Map.new }
	Object.defineProperty fb, '__response__', { value: Map.new }
	Object.defineProperty fb, '__storage__', { value: fb.storage }
	fb.firestore
