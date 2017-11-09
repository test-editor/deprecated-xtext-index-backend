package org.testeditor.web.xtext.index

import com.google.inject.AbstractModule
import org.eclipse.xtext.resource.IResourceDescriptions
import org.eclipse.xtext.resource.IContainer
import org.eclipse.xtext.resource.impl.SimpleResourceDescriptionsBasedContainerManager

class XtextIndexModule extends AbstractModule {
	
	override protected configure() {
		binder.bind(IResourceDescriptions).to(XtextIndex)
	}

}
