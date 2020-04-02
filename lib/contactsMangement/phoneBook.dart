import 'package:firebase_auth/firebase_auth.dart';
import 'package:com/model/uploadContact.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import 'package:com/Animation/bottomAnimation.dart';

class PhoneBook extends StatefulWidget {
  final FirebaseUser user;
  PhoneBook({this.user});
  @override
  _PhoneBookState createState() => _PhoneBookState();
}

class _PhoneBookState extends State<PhoneBook> {
  List<Contact> _contacts;

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  refreshContacts() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      var contacts =
          (await ContactsService.getContacts(withThumbnails: false)).toList();
      setState(() {
        _contacts = contacts;
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  @override
  initState() {
    super.initState();
    refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Book'),
      ),
      body: _contacts != null
          ? Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color(0xff0D2C4F),
                    Color(0xff0D2C4F),
                    Color(0xff1D2631),
                    Color(0xff1D2631),
                  ])),
              child: SafeArea(
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: height * 0.01,
                      color: Colors.white54,
                    );
                  },
                  itemCount: _contacts?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    Contact c = _contacts?.elementAt(index);
                    return ItemsTile(widget.user, c, c.phones);
                  },
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Color(0xff1D2631)),
              ),
            ),
    );
  }
}

class ItemsTile extends StatefulWidget {
  ItemsTile(this.user, this.c, this._items);

  final Contact c;
  final Iterable<Item> _items;
  final FirebaseUser user;

  @override
  _ItemsTileState createState() => _ItemsTileState();
}

class _ItemsTileState extends State<ItemsTile> {
  List<UploadContact> uploadContactList = List();

  UploadContact uploadContact;

  DatabaseReference contactRef;

  @override
  void initState() {
    super.initState();
    uploadContact = UploadContact(" ", " ");
    contactRef = FirebaseDatabase.instance.reference().child(widget.user.phoneNumber);
    contactRef.onChildAdded.listen(_onContactAdded);
    FirebaseDatabase database = new FirebaseDatabase();
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
  }

  void contactToBeUpload() {
    contactRef.push().set(uploadContact.toJson());
  }

  _onContactAdded(Event event) {
    setState(() {
      uploadContactList.add(UploadContact.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return WidgetAnimator(
      ListTile(
        onTap: () {
          uploadContact.name = widget.c.displayName;
          var phoneNumber = widget._items.map((i) => i.value ?? " ").toString();
          var newPhone = phoneNumber.replaceAll(RegExp(r"[^\name\w]"), '');
          if (newPhone.length == 12){
            uploadContact.phoneNumber = "+" + newPhone.substring(0, newPhone.length);
          }
          if (newPhone.length == 11){
            uploadContact.phoneNumber = "+92" + newPhone.substring(1, newPhone.length);
          }
          if (newPhone.length > 12) {
            var start2Number = newPhone.substring(0,2);
            if (start2Number == "92"){
              uploadContact.phoneNumber = "+" + newPhone.substring(0, 12);
            }
            if (start2Number == "03") {
              uploadContact.phoneNumber = "+92" + newPhone.substring(1, newPhone.length);
            }
          }
          contactToBeUpload();
          Toast.show("${widget.c.displayName}" + " Added!", context, backgroundRadius: 5, backgroundColor: Colors.blue, duration: 2);
        },
        leading: CircleAvatar(
          child: Text('${widget.c.displayName[0]}'),
          radius: height * 0.025,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.c.displayName ?? "",
              style: TextStyle(color: Colors.white, fontSize: height * 0.022),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Column(
              children: widget._items
                  .map(
                    (i) => Text(
                      i.value + "\t" ?? "",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                  .toList(),
            )
          ],
        ),
        trailing: Text(
          'Tap',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
