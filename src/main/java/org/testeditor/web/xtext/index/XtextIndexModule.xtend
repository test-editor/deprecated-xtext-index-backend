package org.testeditor.web.xtext.index

import com.google.inject.AbstractModule
import org.eclipse.xtext.resource.IResourceDescriptions

class XtextIndexModule extends AbstractModule {
	
	override protected configure() {
		binder.bind(IResourceDescriptions).to(XtextIndex)
	}

}
